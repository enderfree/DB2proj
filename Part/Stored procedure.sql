--Q2.Borrowing Book--
CREATE OR REPLACE PROCEDURE Borrow_Book(i_card_id NUMBER, i_book_id NUMBER)
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