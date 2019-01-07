# MySQL_EmployeesReport

## For practice with MySQL, I implemented a MySQL script that solved the following purpose:

In a fictional company, until now, the evidence of employee (such as first name, last name and others) was kept in text documents and the CEO wants to move all the data into a MySQL Database.
After all the info was moved, the administration wants some reports.

### Tasks
1. Create the database called "proiect" (that means project).
  In this database, create a *procedure* called "tabele" (meaning tables) which serves for:
    - Delete and recreate the following tables: *Salariati* (Employees), *Echipe* (Teams), *Productie* (Production), *Tabela_veche* (The old table). The data in the tables will be extracted from the old table which will be readed from file.
    - Index creation: Each table, excepting the old one, shall have a *primary key* and an *unique index* made by the "Prenume" (First Name) and the "Nume" (Last Name) columns.
    - The procedure cand be executed as many times as needed.
    
2. Create a *function* that recieves two parameters of type text: date and hour and will convert the input into the correct MySQL format.

3. Create a *trigger* that will use the function mentioned above to fill in the formated date and hour.

4. Import data from the fisier.txt file.

5. The data shall be splitted corecttly among the new tables.

6. Create a "rapoarte" procedure that shows the following reports:
    - List the currency made by every employee, for every executed unit, if the price of 1 unit is 25 monetary units.
    - Which team produced the biggest number of units (display the team leader name)
    - The employee that produced the biggest number of units in 2017 (if there are multiple employees, display the first in an alphabetical order)
    - What is the number of units produced per day of week
    - The teams that produced at least 1800 units in 2014
    - The month in which was registered the biggest production by the team that has the biggest number of members.
7. (Optionally) Create a *view* that will act as the olt table.

*Note:* I used this view for task 6.
