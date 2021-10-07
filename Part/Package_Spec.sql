 CREATE OR REPLACE PACKAGE MANAGE_BOOKS
 AS	
 	--Insert a new book, default value of Status = 'AVAILABLE'
 	PROCEDURE ADD_BOOK(i_Book_ID IN NUMBER, i_Title IN VARCHAR2, i_Category IN VARCHAR2, i_Cost NUMBER);
 	
 	-- Deletes an existing book
 	PROCEDURE REMOVE_BOOK(i_Book_ID IN NUMBER);
 	
 	--Display all the book of the given i_Status
 	PROCEDURE LIST_ALL_BOOKS (i_Status IN VARCHAR2) ;
 	
 	--Update the Status of the given i_Book_ID
 	PROCEDURE UPDATE_BOOK_Status(i_Book_ID IN NUMBER, i_Status IN VARCHAR2);
 	
 	--Read the status of the given i_Book_ID
 	FUNCTION  GET_BOOK_STATUS(i_Book_ID IN NUMBER) RETURN VARCHAR2;
 	
 END MANAGE_BOOKS;
 /
 

