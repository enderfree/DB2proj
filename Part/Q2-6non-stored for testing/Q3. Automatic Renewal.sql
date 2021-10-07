SET SERVEROUTPUT ON
DECLARE
	v_card_id NUMBER := &sv_card_id;
	v_book_id NUMBER := &sv_book_id;
	
	PROCEDURE Automatic_Renewal(i_card_id NUMBER, i_book_id NUMBER)
	IS
	v_book_status VARCHAR2(10);
	v_card_status VARCHAR2(10);
	v_due_date DATE;
	v_return_date DATE;
	v_can_renew BOOLEAN := TRUE;
	BEGIN
		SELECT status INTO v_book_status FROM Book WHERE i_book_id = book_id;
		SELECT status INTO v_card_status FROM Card WHERE i_card_id = card_id;
		SELECT due_date INTO v_due_date FROM Rental WHERE i_book_id = book_id AND i_card_id = card_id;
		SELECT return_date INTO v_return_date FROM Rental WHERE i_book_id = book_id AND i_card_id = card_id;
		
		IF v_book_status LIKE 'RENTED' THEN --Not 'RESERVED' would not work because lost book are not reserved and you don't need to reserve available books
			IF v_card_status LIKE 'ACTIVE' THEN --Cards are either active or innactive
				IF v_return_date IS NULL THEN
					IF v_due_date < CURRENT_DATE THEN
						v_can_renew := FALSE;
					END IF;
				END IF;
				
				IF v_can_renew THEN
					INSERT INTO Rental(card_id, book_id, rent_date, due_date, return_date) VALUES (i_card_id, i_book_id, CURRENT_DATE, CURRENT_DATE + 15, NULL);
					DBMS_OUTPUT.PUT_LINE('Renewal successfull!');
				ELSE
					DBMS_OUTPUT.PUT_LINE('Take care of your late fees before renewing.');
				END IF;
			ELSE
				DBMS_OUTPUT.PUT_LINE('Activate your card before renewing.');
			END IF;
		ELSE
			DBMS_OUTPUT.PUT_LINE('This book isn''t rented or is reserved.');
		END IF;
	
	EXCEPTION WHEN NO_DATA_FOUND THEN
		DBMS_OUTPUT.PUT_LINE('The informations you entered doesn''t match the database.');
	
	END Automatic_Renewal;
	
BEGIN
	Automatic_Renewal(v_card_id, v_book_id);

END;
/
.