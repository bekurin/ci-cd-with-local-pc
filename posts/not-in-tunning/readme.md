# not-in 쿼리에서 인덱스를 사용해보자.

개발과 관련 없는 직원의 수를 집계하고 싶을 때 어떻게 해야할까?

```
select * from employees as e1
    inner join titles on titles.emp_no = e1.emp_no
	where titles.title not in ("Engineer", "Senior Engineer", "Assistant Engineer", "Technique Leader");

-> Nested loop inner join  (cost=137539 rows=265598) (actual time=0.131..266 rows=200268 loops=1)
    -> Filter: (titles.title not in ('Engineer','Senior Engineer','Assistant Engineer','Technique Leader'))  (cost=44579 rows=265598) (actual time=0.103..154 rows=200268 loops=1)
        -> Table scan on titles  (cost=44579 rows=442664) (actual time=0.0973..84.5 rows=443308 loops=1)
    -> Single-row index lookup on employees using PRIMARY (emp_no=titles.emp_no)  (cost=0.25 rows=1) (actual time=443e-6..462e-6 rows=1 loops=200268)
```

not-in을 사용하면 직관적으로 쿼리를 생성할 수 있지만 index를 사용하지 못한다. 그도 그럴 것이 index는 빠르게 값을 찾기 위함인데 not-in은 포함되지 않는 값을 찾아야하기 때문이다.

실행 계획에서도 알 수 있듯이 not-in은 table scan을 하여 포함되지 않는 값을 하나하나 filtering 한다.

```
select * from employees as e1
    left outer join (
		select emp_no from titles as t1 where title in ("Staff", "Senior Staff", "Manager")
        ) as st1 on st1.emp_no = e1.emp_no
	where st1.emp_no is not null;

-> Nested loop inner join  (cost=86411 rows=119519) (actual time=0.155..242 rows=200268 loops=1)
    -> Filter: ((t1.emp_no is not null) and (t1.title in ('Staff','Senior Staff','Manager')) and (t1.emp_no is not null))  (cost=44579 rows=119519) (actual time=0.125..133 rows=200268 loops=1)
        -> Covering index scan on t1 using PRIMARY  (cost=44579 rows=442664) (actual time=0.115..69.4 rows=443308 loops=1)
    -> Single-row index lookup on e1 using PRIMARY (emp_no=t1.emp_no)  (cost=0.25 rows=1) (actual time=430e-6..450e-6 rows=1 loops=200268)
```

개선을 하기 위해서는 left outer join을 사용할 수 있다. 개발 직군이 아닌 직원들을 left outer join을 하게 되면 개발 직군인 직원들의 emp_no가 null이 되고, 개발 직군이 아닌 직원 수를 계산할 때는 emp_no가 null이 아닌 경우만 집계하면 된다.

실행 계획에서도 convering index를 사용하는 것을 알 수 있다.
