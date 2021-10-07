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
.