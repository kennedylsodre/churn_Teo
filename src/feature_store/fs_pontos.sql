}WITH tb_points as (

     SELECT 
        cst.idCustomer
        ,SUM(trn.pointsTransaction) AS saldopoints21dias 

        ,sum( 
            case 
                when dtTransaction >= DATE({data},'-14 day') then trn.pointsTransaction 
                else 0 
            end ) as saldopoints14days 

        ,sum( 
            case 
                when dtTransaction >= DATE({data},'-7 day') then trn.pointsTransaction 
                else 0 
            end ) as saldopoints7days 

        ,SUM( 
            CASE 
                WHEN trn.pointsTransaction >0 then trn.pointsTransaction 
                else 0 
            end ) as totalpointsacumulado21dias

        ,SUM( 
            CASE 
                WHEN trn.pointsTransaction >0 and trn.dtTransaction >= DATE({data},'-14 day') then trn.pointsTransaction 
                else 0 
            end ) as totalpointsacumulado14dias

        ,SUM( 
            CASE 
                WHEN trn.pointsTransaction >0 and trn.dtTransaction >= DATE({data},'-7 day') then trn.pointsTransaction 
                else 0 
            end ) as totalpointsacumulado7dias

        ,SUM( 
            CASE 
                WHEN trn.pointsTransaction <0 then trn.pointsTransaction 
                else 0 
            end ) as totalpointsresgatados21dias

        ,SUM( 
            CASE 
                WHEN trn.pointsTransaction <0 and trn.dtTransaction >= DATE({data},'-14 day') then trn.pointsTransaction 
                else 0 
            end ) as totalpointsresgatados14dias

        ,SUM( 
            CASE 
                WHEN trn.pointsTransaction <0 and trn.dtTransaction >= DATE({data},'-7 day') then trn.pointsTransaction 
                else 0 
            end ) as totalpointsresgatados7dias
    
    FROM customers cst
    LEFT JOIN transactions trn 
        ON cst.idCustomer = trn.idCustomer 
    WHERE trn.dtTransaction < {data}
    AND trn.dtTransaction >= DATE({data},'-21 day')
    GROUP BY cst.idCustomer
),

tb_vida as (
    SELECT
        t1.idCustomer 
        ,sum(t2.pointsTransaction) as saldopointsvida 

        ,sum(
            CASE
                when t2.pointsTransaction >0 then t2.pointsTransaction 
                else 0 
            end ) as pointsacumuladovida

        ,sum(
            CASE
                when t2.pointsTransaction <0 then t2.pointsTransaction 
                else 0 
            end ) as pointsresgatadosvida

        ,CAST(max(julianday({data}) - julianday(dtTransaction)) as INTEGER) +1 as diasdevida
    FROM tb_points T1 
    LEFT JOIN transactions t2 
        on t1.idCustomer = t2.idCustomer 
    WHERE t2.dtTransaction <= {data}
    GROUP BY t1.idCustomer

),

tb_join as (

    SELECT 
        t1.*
        ,t2.saldopointsvida 
        ,t2.pointsacumuladovida
        ,t2.pointsresgatadosvida 
        ,1.0 * t2.pointsacumuladovida / diasdevida as pointspordia
    FROM tb_points t1 
    LEFT JOIN tb_vida t2 
        on t1.idCustomer = t2.idCustomer

)

SELECT  
    *
    ,{data}as dtRef
FROM tb_join 

