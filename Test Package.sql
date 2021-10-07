SET SERVEROUTPUT ON
DECLARE
	v_book_status Book.status%TYPE;
BEGIN
--Stored Procedure
	--Borrow_Book(v_card_id, v_book_id);
	--Automatic_Renewal(v_card_id, v_book_id);
	--Reserve_Book(v_card_id, v_book_id);
	--Return_Book(v_card_id, v_book_id);
	--Lost_Book(v_card_id, v_book_id);

--Package
	--MANAGE_BOOKS.ADD_BOOK(123, '50ShadyGay', 'Bromance', 59);
	--MANAGE_BOOKS.REMOVE_BOOK(123);
	--MANAGE_BOOKS.LIST_ALL_BOOKS('LOST');
	--MANAGE_BOOKS.UPDATE_BOOK_Status(9158, 'LOST');
	
	v_book_status := MANAGE_BOOKS.GET_BOOK_STATUS(9158);
	DBMS_OUTPUT.PUT_LINE(v_book_status);
END;
/
.