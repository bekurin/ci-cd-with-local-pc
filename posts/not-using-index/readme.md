# 인덱스를 사용하지 못하는 경우


## 1. like 명령어에서 %를 검색어 앞에 사용하는 경우
> "%검색어"와 같이 like 명령어를 구성하는 경우

```
select * from employees where first_name like "%b";

-> Filter: (employees.first_name like '%b')  (cost=30179 rows=33271) (actual time=0.437..120 rows=2008 loops=1)
    -> Table scan on employees  (cost=30179 rows=299468) (actual time=0.0816..94.5 rows=300024 loops=1)
```


## 2. 복합 인덱스에 정의된 첫번째 컬럼으로 조건을 조합하지 않은 경우
> 인덱스 첫번째 컬럼을 조건에 포함하지 않는 경우

```
select * from employees	where last_name like "B%" and birth_date like "1953%";

-> Filter: ((employees.last_name like 'B%') and (employees.birth_date like '1953%'))  (cost=30179 rows=3696) (actual time=0.171..113 rows=2117 loops=1)
    -> Table scan on employees  (cost=30179 rows=299468) (actual time=0.138..89.2 rows=300024 loops=1)
```

```
select * from employees	where first_name like "B%" and birth_date like "1953%";

-> Index range scan on employees using idx_first_last_name over ('B' <= first_name <= 'B????????????????????????????????????????????????????'), with index condition: ((employees.first_name like 'B%') and (employees.birth_date like '1953%'))  (cost=11796 rows=26212) (actual time=0.0558..14.1 rows=969 loops=1)
```

## 3. 부정형을 사용하는 경우
> 부정형 `<>`, `!=`, `not in`을 사용하는 경우
