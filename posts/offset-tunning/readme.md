# offset 최적화

많은 양의 데이터가 저장되어 있을 때 paging 처리를 위해 offset, limit는 반드시 사용되는데요. paging에서 offset이 커지는 것은 문제가 될 수 있습니다.

```
select birth_date, first_name, last_name from employees
	order by birth_date limit 10000, 100;

-> Limit/Offset: 100/10000 row(s)  (cost=30179 rows=100) (actual time=148..148 rows=100 loops=1)
    -> Sort: employees.birth_date, limit input to 10100 row(s) per chunk  (cost=30179 rows=299468) (actual time=147..147 rows=10100 loops=1)
        -> Table scan on employees  (cost=30179 rows=299468) (actual time=0.119..77.2 rows=300024 loops=1)

```


```
select birth_date, first_name, last_name from employees
	inner join  (select emp_no from employees order by birth_date limit 10000, 100) as sub_employees on sub_employees.emp_no = employees.emp_no;

-> Nested loop inner join  (cost=32728 rows=100) (actual time=105..105 rows=100 loops=1)
    -> Table scan on sub_employees  (cost=30189..30193 rows=100) (actual time=105..105 rows=100 loops=1)
        -> Materialize  (cost=30189..30189 rows=100) (actual time=105..105 rows=100 loops=1)
            -> Limit/Offset: 100/10000 row(s)  (cost=30179 rows=100) (actual time=105..105 rows=100 loops=1)
                -> Sort: employees.birth_date, limit input to 10100 row(s) per chunk  (cost=30179 rows=299468) (actual time=105..105 rows=10100 loops=1)
                    -> Table scan on employees  (cost=30179 rows=299468) (actual time=0.0878..59.2 rows=300024 loops=1)
    -> Single-row index lookup on employees using PRIMARY (emp_no=sub_employees.emp_no)  (cost=0.25 rows=1) (actual time=0.00165..0.00166 rows=1 loops=100)

```
