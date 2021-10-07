SET SERVEROUTPUT ON
DECLARE
	v_card_id NUMBER := &sv_card_id;
	v_book_id NUMBER := &sv_book_id;


	PROCEDURE Borrow_Book(i_card_id NUMBER, i_book_id NUMBER)
	IS
	v_card_status VARCHAR2(10);
	v_book_status VARCHAR2(10);
	BEGIN
		SELECT status INTO v_card_status FROM Card WHERE card_id = i_card_id;
		SELECT status INTO v_book_status FROM Book WHERE book_id = i_card_id;
		IF v_card_status LIKE 'ACTIVE' THEN 
			IF v_book_status LIKE 'AVAILABLE' THEN
				INSERT INTO Rental(card_id, book_id, rent_date, due_date, return_date) VALUES (i_card_id, i_book_id, CURRENT_DATE, CURRENT_DATE + 15, NULL);
				DBMS_OUTPUT.PUT_LINE('Tanks for your rental!');
			ELSE
				DBMS_OUTPUT.PUT_LINE('This book isn''t available');
			END IF;
		ELSE
			DBMS_OUTPUT.PUT_LINE('Activate your card to rent');
		END IF;
	EXCEPTION WHEN NO_DATA_FOUND THEN
		DBMS_OUTPUT.PUT_LINE('The informations you entered doesn''t match the database.');
	END Borrow_Book;

BEGIN
	Borrow_Book(v_card_id, v_book_id);

END;
/
.