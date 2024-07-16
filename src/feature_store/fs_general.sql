WITH tb_rfv as ( 
    SELECT 
        cst.idCustomer
        ,COUNT(DISTINCT trn.dtTransaction) as Freq
        -- ,cst.PointsCustomer as vlr_pontos_cst
        -- ,cst.flEmail 
        ,CAST(min(julianday('2024-07-04') - julianday(dtTransaction)) as INTEGER) + 1 as frequencia
        ,sum(IfNULL(pointsTransaction,0)) as vlr_pontos
    FROM customers cst
    LEFT JOIN transactions trn 
        ON cst.idCustomer = trn.idCustomer 
    LEFT JOIN transactions_product trn_prd 
        on trn_prd.idTransaction = trn.idTransaction
    WHERE trn.dtTransaction < '2024-07-04'
    AND trn.dtTransaction >= DATE('2024-07-04','-21 day')
    GROUP BY cst.idCustomer
) 

,tb_idade as ( 
   SELECT 
    rfv.idCustomer,
    CAST(MAX(julianday('2024-07-04') - julianday(trn.dtTransaction)) AS INTEGER) + 1 AS idadeBaseDias
    FROM 
    tb_rfv rfv 
LEFT JOIN 
    transactions trn 
    ON rfv.idCustomer = trn.idCustomer
GROUP BY 
    rfv.idCustomer

)

SELECT 
    '2024-07-04' as dtRef
    ,rfv.*
    ,idade.idadeBaseDias
    ,cst.flEmail
FROM tb_rfv rfv 
LEFT JOIN tb_idade idade 
    on idade.idCustomer = rfv.idCustomer
LEFT join customers cst 
    on cst.idCustomer = rfv.idCustomer

