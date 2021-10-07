SET SERVEROUTPUT ON
DECLARE
	v_card_id NUMBER := &sv_card_id;
	v_book_id NUMBER := &sv_book_id;
	
	PROCEDURE Reserve_Book(i_card_id NUMBER, i_book_id NUMBER)
	IS
	v_book_status VARCHAR2(10);
	v_card_status VARCHAR2(10);
	BEGIN
		SELECT status INTO v_book_status FROM Book WHERE i_book_id = book_id;
		SELECT status INTO v_card_status FROM Card WHERE i_card_id = card_id;
		
		IF v_book_status LIKE 'RESERVED' THEN
			DBMS_OUTPUT.PUT_LINE('This book is already reserved.');
		ELSE
			IF v_card_status LIKE 'INNACTIVE' THEN
				DBMS_OUTPUT.PUT_LINE('Activate your card before making reservations');
			ELSE
				INSERT INTO Reservation(card_id, book_id, reservation_date) VALUES (i_card_id, i_book_id, CURRENT_DATE);
				UPDATE Book SET status = 'RESERVED' WHERE book_id = i_book_id;
				DBMS_OUTPUT.PUT_LINE('Successful reservation!');
			END IF;
		END IF;
	
	EXCEPTION WHEN NO_DATA_FOUND THEN
		DBMS_OUTPUT.PUT_LINE('The informations you entered doesn''t match the database.');
	
	END Reserve_Book;
	
BEGIN
	Reserve_Book(v_card_id, v_book_id);

END;
/
.