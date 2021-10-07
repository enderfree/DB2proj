SET SERVEROUTPUT ON
DECLARE
	v_card_id NUMBER := &sv_card_id;
	v_book_id NUMBER := &sv_book_id;
	
	PROCEDURE Return_Book(i_card_id NUMBER, i_book_id NUMBER)
	IS
	v_book_status VARCHAR2(10);
	v_due_date DATE;
	v_fees NUMBER;
	BEGIN
		SELECT status INTO v_book_status FROM Book WHERE i_book_id = book_id;
		SELECT due_date INTO v_due_date FROM Rental WHERE i_book_id = book_id AND i_card_id = card_id;
		SELECT late_fees INTO v_fees FROM Card WHERE i_card_id = card_id;
		
		IF v_book_status NOT LIKE 'RESERVED' THEN
			UPDATE Book SET status = 'AVAILABLE' WHERE i_book_id = book_id;
		END IF;
		
		UPDATE Rental SET return_date = CURRENT_DATE WHERE i_book_id = book_id AND i_card_id = card_id;
		
		IF CURRENT_DATE > v_due_date THEN
			UPDATE Card SET status = 'INNACTIVE' WHERE i_card_id = card_id;
			UPDATE Card SET late_fees = (0.25*(CURRENT_DATE-v_due_date)+v_fees) WHERE i_card_id = card_id;
		END IF;
		
		DBMS_OUTPUT.PUT_LINE('Thanks for returning the book!');
	
	EXCEPTION WHEN NO_DATA_FOUND THEN
		DBMS_OUTPUT.PUT_LINE('The informations you entered doesn''t match the database.');
	
	END Return_Book;
	
BEGIN
	Return_Book(v_card_id, v_book_id);

END;
/
.