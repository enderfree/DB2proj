CREATE OR REPLACE PACKAGE BODY MANAGE_BOOKS
AS	
--Insert a new book, default value of Status = 'AVAILABLE'
PROCEDURE ADD_BOOK(i_Book_ID IN NUMBER, i_Title IN VARCHAR2, i_Category IN VARCHAR2, i_Cost NUMBER)
AS
BEGIN
	INSERT INTO Book (book_id, title, category, status, lost_cost) VALUES (i_Book_ID, i_Title, i_Category, 'AVAILABLE', i_Cost);
	COMMIT;
EXCEPTION WHEN OTHERS THEN
	DBMS_OUTPUT.PUT_LINE('You didn''t give all the requirements to insert a book or gave us its status to.');
END ADD_BOOK;

-- Deletes an existing book
PROCEDURE REMOVE_BOOK(i_Book_ID IN NUMBER)
AS
BEGIN
	DELETE FROM Book WHERE book_id = i_Book_ID;
	COMMIT;
EXCEPTION WHEN NO_DATA_FOUND THEN
	DBMS_OUTPUT.PUT_LINE('This book already doesn''t feature in this database.');
END REMOVE_BOOK;

--Display all the book of the given i_Status
PROCEDURE LIST_ALL_BOOKS (i_Status IN VARCHAR2)
AS
	CURSOR c_matching_books IS SELECT * FROM Book WHERE status LIKE i_Status;
BEGIN
	FOR books IN c_matching_books LOOP
		DBMS_OUTPUT.PUT_LINE(books.book_id || ' ' || books.title || ' ' || books.category || ' ' || books.status || ' ' || books.lost_cost);
	END LOOP;
EXCEPTION WHEN NO_DATA_FOUND THEN
	DBMS_OUTPUT.PUT_LINE('No book in this database are ' || i_Status);
END LIST_ALL_BOOKS;

--Update the Status of the given i_Book_ID
PROCEDURE UPDATE_BOOK_Status(i_Book_ID IN NUMBER, i_Status IN VARCHAR2)
AS
BEGIN
	UPDATE Book SET status = i_Status WHERE book_id = i_Book_ID;
	COMMIT;
EXCEPTION WHEN NO_DATA_FOUND THEN
	DBMS_OUTPUT.PUT_LINE('The book wasn''found in the database so its status wasn''t updated.');
END UPDATE_BOOK_Status;

--Read the status of the given i_Book_ID
FUNCTION  GET_BOOK_STATUS(i_Book_ID IN NUMBER) 
RETURN VARCHAR2
AS
v_errorMessage VARCHAR2(20) := 'No book have this id';
v_book_status Book.status%TYPE;
BEGIN
	SELECT status INTO v_book_status FROM Book WHERE book_id = i_Book_ID;
	RETURN v_book_status;
EXCEPTION WHEN NO_DATA_FOUND THEN
	DBMS_OUTPUT.PUT_LINE(v_errorMessage);
	RETURN v_errorMessage;
END GET_BOOK_STATUS;

END MANAGE_BOOKS;
/