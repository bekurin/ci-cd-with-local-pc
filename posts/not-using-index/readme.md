# 인덱스를 사용하지 못하는 경우
사전에 first_name, last_name, birh_date 순서로 복합 인덱스가 생성된 것을 가정합니다.

## 1. like 명령어에서 %를 검색어 앞에 사용하는 경우
> "%검색어"와 같이 like 명령어를 구성하는 경우

```
select * from employees where first_name like "%b";

-> Filter: (employees.first_name like '%b')  (cost=30179 rows=33271) (actual time=0.437..120 rows=2008 loops=1)
    -> Table scan on employees  (cost=30179 rows=299468) (actual time=0.0816..94.5 rows=300024 loops=1)
```
복합 인덱스의 첫번째 컬럼으로 first_name이 있지만 실행 계획을 보면 인덱스를 전형 사용하지 못하는 것을 확인할 수 있습니다.

반대로 like 명령어 뒤에 %를 사용하면 어떻게 될까요?
<쿼리>
<실행계획>

보시는 것처럼 사전에 정의한 복합 인덱스를 활용하여 빠르게 검색하는 것을 알 수 있습니다.

## 2. 복합 인덱스에 정의된 첫번째 컬럼으로 조건을 조합하지 않은 경우
> 인덱스 첫번째 컬럼을 조건에 포함하지 않는 경우

복합 인덱스의 경우 첫번째 컬럼을 조건에 포함하지 않으면 다른 컬럼들이 인덱스가 걸려있다고 하더라도 인덱스를 사용하지 못합니다.
```
select * from employees	where last_name like "B%" and birth_date like "1953%";

-> Filter: ((employees.last_name like 'B%') and (employees.birth_date like '1953%'))  (cost=30179 rows=3696) (actual time=0.171..113 rows=2117 loops=1)
    -> Table scan on employees  (cost=30179 rows=299468) (actual time=0.138..89.2 rows=300024 loops=1)
```
위 쿼리의 경우 두번째 컬럼인 last_name부터 검색 조건을 포함시켰는데요. 실행 계획에서 확인할 수 있듯이 인덱스를 사용하지 못합니다.

```
select * from employees	where first_name like "B%" and birth_date like "1953%";

-> Index range scan on employees using idx_first_last_name over ('B' <= first_name <= 'B????????????????????????????????????????????????????'), with index condition: ((employees.first_name like 'B%') and (employees.birth_date like '1953%'))  (cost=11796 rows=26212) (actual time=0.0558..14.1 rows=969 loops=1)
```
위 쿼리의 경우 첫번째 컬럼부터 검색 조건을 설정해주었는데요. 실행 계획에서도 볼 수 있듯이 인덱스 range scan을 사용하여 검색을 하는 것을 알 수 있습니다.

## 3. 부정형을 사용하는 경우
> 부정형 `<>`, `!=`, `not in`을 사용하는 경우

<first_name이 B로 시작하지 않는 경우 쿼리>

<first_name이 B로 시작하는 경우 쿼리>
