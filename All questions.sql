--Q1.Generate username and password--
SET SERVEROUTPUT ON
DECLARE
	CURSOR c_employees IS 
	SELECT first_name, last_name, hire_date, employee_id FROM employee FOR UPDATE OF username, password;
	 
	CURSOR c_member IS
	SELECT last_name, member_id, first_name, zip FROM member FOR UPDATE OF username, password;
 
BEGIN
	--Member
	FOR r_member IN c_member
	LOOP
		--SET username
		UPDATE Member 
		SET username = UPPER(
			SUBSTR(r_member.last_name, 1, 1))||LOWER(SUBSTR( --substr does weird thigs
				r_member.last_name, 2, 1))||r_member.member_id --I should read more on it
		WHERE r_member.member_id = member_id;
		
		--SET password
		UPDATE Member 
			SET password = '00'||UPPER(SUBSTR(r_member.first_name, 0, 2))||r_member.zip 
			WHERE r_member.member_id = member_id;
	END LOOP;
	
	--Employee
	FOR r_employee IN c_employees
	LOOP
		--SET username
		UPDATE Employee SET username = LOWER(SUBSTR(r_employee.first_name, 0, 1)
			||SUBSTR(r_employee.last_name, 0, 9)) 
			WHERE r_employee.employee_id = employee_id;
		--SET password
		UPDATE Employee SET password = UPPER(SUBSTR(r_employee.first_name, 0, 2))
			||TO_CHAR(r_employee.hire_date, 'DD')||UPPER(SUBSTR(
			r_employee.last_name, 0, 2))||TO_CHAR(r_employee.hire_date, 'YYYY') 
			WHERE r_employee.employee_id = employee_id;
	END LOOP;
	COMMIT;
EXCEPTION WHEN NO_DATA_FOUND THEN
	DBMS_OUTPUT.PUT_LINE('Your tables are empty');
END;
/

--Q2.Borrowing Book--
CREATE OR REPLACE PROCEDURE Borrow_Book(i_card_id NUMBER, i_book_id NUMBER)
IS
v_card_status VARCHAR2(10);
v_book_status VARCHAR2(10);
BEGIN
	SELECT status INTO v_card_status FROM Card WHERE card_id = i_card_id;
	SELECT status INTO v_book_status FROM Book WHERE book_id = i_book_id;
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
	COMMIT;
EXCEPTION WHEN NO_DATA_FOUND THEN
	DBMS_OUTPUT.PUT_LINE('The informations you entered doesn''t match the database.');
END Borrow_Book;
/

--Q3. Automatic Renewal--
CREATE OR REPLACE PROCEDURE Automatic_Renewal(i_card_id NUMBER, i_book_id NUMBER)
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
	COMMIT;

EXCEPTION WHEN NO_DATA_FOUND THEN
	DBMS_OUTPUT.PUT_LINE('The informations you entered doesn''t match the database.');

END Automatic_Renewal;
/

--Q4.Making Reservations--
CREATE OR REPLACE PROCEDURE Reserve_Book(i_card_id NUMBER, i_book_id NUMBER)
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
	COMMIT;

EXCEPTION WHEN NO_DATA_FOUND THEN
	DBMS_OUTPUT.PUT_LINE('The informations you entered doesn''t match the database.');

END Reserve_Book;
/

--Q5.Returning Book--
CREATE OR REPLACE PROCEDURE Return_Book(i_card_id NUMBER, i_book_id NUMBER)
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
	COMMIT;

EXCEPTION WHEN NO_DATA_FOUND THEN
	DBMS_OUTPUT.PUT_LINE('The informations you entered doesn''t match the database.');

END Return_Book;
/

--Q6.Lost Books--
CREATE OR REPLACE PROCEDURE Lost_Book(i_card_id NUMBER, i_book_id NUMBER)
IS
v_fees NUMBER;
v_cost NUMBER;
BEGIN
	SELECT late_fees INTO v_fees FROM Card WHERE i_card_id = card_id;
	SELECT lost_cost INTO v_cost FROM Book WHERE i_book_id = book_id;

	UPDATE Book SET status = 'LOST' WHERE i_book_id = book_id;
	UPDATE Card SET status = 'INNACTIVE' WHERE i_card_id = card_id; 
	UPDATE Card SET late_fees = (v_fees + v_cost) WHERE i_card_id = card_id;
	COMMIT;
EXCEPTION WHEN NO_DATA_FOUND THEN
	DBMS_OUTPUT.PUT_LINE('The informations you entered doesn''t match the database.');

END Lost_Book;
/

--Loading spec for Q7--
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
 
--Q7 Defining a body to this package--
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