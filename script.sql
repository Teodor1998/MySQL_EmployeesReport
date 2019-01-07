create schema if not exists proiect;
use proiect;

DELIMITER $$

-- 1.
create procedure tabele()
begin
	-- Mai intai voi sterge tabelele, daca exista:
    SET FOREIGN_KEY_CHECKS=0;
    
	drop table if exists Salariati;
    drop table if exists Echipe;
    drop table if exists Productie;
    drop table if exists Tabela_veche;
    
    SET FOREIGN_KEY_CHECKS=1;
    
    -- Acum voi crea noile tabele:
     create table Salariati (id_salariat int AUTO_INCREMENT, nume varchar(20), prenume varchar(20), unique(nume, prenume), primary key(id_salariat));
	 create table Echipe (id_echipa int AUTO_INCREMENT, nume_sef varchar(20), prenume_sef varchar(20), unique(nume_sef, prenume_sef), primary key(id_echipa));
	 create table Productie (id_prod int AUTO_INCREMENT, data_ora datetime, id_echipa int, id_salariat int, cantitate int, foreign key(id_echipa) references Echipe(id_echipa), foreign key(id_salariat) references Salariati(id_salariat), primary key(id_prod));
     create table Tabela_veche (data_raw text, ora_raw text, nume_angajat varchar(20), prenume_angajat varchar(20), nume_sef varchar(20), prenume_sef varchar(20), nr_piese int, fulldate datetime);
end$$

call tabele$$

-- 2.
create function formatare_data(data_raw text, ora_raw text) returns datetime DETERMINISTIC
begin
	-- se putea si fara variabila, dar am creat si variabila for practice
	declare var text;
    set var = concat(substr(data_raw, 5, 4), '-', mid(data_raw, 3, 2), '-', left(data_raw, 2), ' ', left(ora_raw, 2), '-', mid(ora_raw, 3, 2), '-', right(ora_raw, 2));
    return var;
end$$

-- 3.
create trigger formatare_insert before insert on Tabela_veche for each row
begin
	set new.fulldate = formatare_data(new.data_raw, new.ora_raw);
end$$

DELIMITER ;

-- 4.
set global local_infile = 1;

load data infile 'fisier.txt'
into table Tabela_veche
-- tab e separatorul default deci nu il voi mai specifica
ignore 1 lines
(data_raw, ora_raw, nume_angajat, prenume_angajat, nume_sef, prenume_sef, nr_piese);


-- 5.1.
insert into Salariati (nume, prenume) select distinct nume_angajat, prenume_angajat from Tabela_veche;
insert into Echipe (nume_sef, prenume_sef) select distinct nume_sef, prenume_sef from Tabela_veche;

insert into Productie (data_ora, id_echipa, id_salariat, cantitate)
select fulldate, t.id_echipa, emp.id_salariat, nr_piese
	from Tabela_veche as old
	join Salariati as emp on 
		old.nume_angajat = emp.nume AND 
        old.prenume_angajat = emp.prenume
	join Echipe as t on 
		old.nume_sef = t.nume_sef AND 
        old.prenume_sef = t.prenume_sef;

-- 6 (Optional).
create or replace view view_tabela_veche (fulldate, nume_angajat, prenume_angajat, nume_sef, prenume_sef, nr_piese)
as select p.data_ora, emp.nume, emp.prenume, t.nume_sef, t.prenume_sef, p.cantitate
	from Productie as p
    join Salariati as emp on emp.id_salariat = p.id_salariat
    join Echipe as t on t.id_echipa = p.id_echipa;

-- 5.2.
DELIMITER $$

create procedure rapoarte()
begin
declare aux_echipa text;

-- lista cu castigul realizat de fiecare salariat, pentru toate piesele executate, daca pretul unei piese este 25 lei;
select sum(nr_piese) * 25 as Castig, concat(nume_angajat, ' ', prenume_angajat) as Salariat
	from view_tabela_veche
group by nume_angajat, prenume_angajat;

-- care echipa(dupa seful de echipa) a produs cel mai mare numar de piese;
select Sef
	from (select sum(nr_piese) as numar_piese, concat(nume_sef, ' ', prenume_sef) as Sef 
		from view_tabela_veche group by Sef)
	as S1
    order by numar_piese DESC limit 1;

-- salariatul care a produs cele mai multe piese in 2017 (daca sunt mai multi primul in ordine alfabetica);
select Salariat from
	(select sum(nr_piese) as numar_piese, concat(nume_angajat, ' ', prenume_angajat) as Salariat
		from view_tabela_veche
	where YEAR(fulldate) = 2017 group by Salariat order by numar_piese DESC, Salariat limit 1) as Sal;

--  care este numarul de piese realizat in fiecare zi a saptamanii;
select sum(nr_piese) as 'Numar Piese', Zi
	from (select nr_piese, dayofweek(fulldate) as Zi
		from view_tabela_veche)
    as S2
group by Zi order by Zi;

-- echipele care au produs cel putin 1800 de piese 2014:
select Sef
	from (select sum(nr_piese) as numar_piese, concat(nume_sef, ' ', prenume_sef) as Sef
		from view_tabela_veche where YEAR(fulldate) = 2014 group by Sef)
	as S3
where numar_piese >= 1800;



-- luna in care a fost realizata cea mai mare productie de echipa cea mai numeroasa.

-- Numele echipei cea mai numeroasa:
set aux_echipa = 
(select Sef from (select count(distinct nume_angajat, prenume_angajat) as numar_angajati, concat(nume_sef, ' ', prenume_sef) as Sef
	from view_tabela_veche group by Sef order by numar_angajati DESC limit 1)
as S4 limit 1);

select Sef
	from (select sum(nr_piese) as numar_piese, month(fulldate) as Luna, concat(nume_sef, ' ', prenume_sef) as Sef
		from view_tabela_veche
	where concat(nume_sef, ' ', prenume_sef) = aux_echipa group by Luna order by numar_piese limit 1) as Sef;
end $$

DELIMITER ;

call rapoarte();
