SET SERVEROUTPUT ON
DECLARE
	v_card_id NUMBER := &sv_card_id;
	v_book_id NUMBER := &sv_book_id;
	
	PROCEDURE Lost_Book(i_card_id NUMBER, i_book_id NUMBER)
	IS
	v_fees NUMBER;
	v_cost NUMBER;
	BEGIN
		SELECT late_fees INTO v_fees FROM Card WHERE i_card_id = card_id;
		SELECT lost_cost INTO v_cost FROM Book WHERE i_book_id = book_id;
	
		UPDATE Book SET status = 'LOST' WHERE i_book_id = book_id;
		UPDATE Card SET status = 'INNACTIVE' WHERE i_card_id = card_id; 
		UPDATE Card SET late_fees = (v_fees + v_cost) WHERE i_card_id = card_id;
	EXCEPTION WHEN NO_DATA_FOUND THEN
		DBMS_OUTPUT.PUT_LINE('The informations you entered doesn''t match the database.');
	
	END Lost_Book;

BEGIN
	Lost_Book(v_card_id, v_book_id);

END;
/
.