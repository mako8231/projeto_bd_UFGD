DELIMITER $$
CREATE procedure servico_cliente(nome_cliente VARCHAR(100))
BEGIN 
	SELECT s.NomeServico, s.Pago, v.Placa, v.Modelo, s.Orcamento 
    FROM servico s 
    NATURAL JOIN veiculo v 
    NATURAL JOIN cliente c 
    WHERE c.Nome 
    LIKE concat('%', nome_cliente, '%');
END $$

CALL servico_cliente("Andre");

DELIMITER $$
CREATE PROCEDURE despesa_mes(data_despesa DATE)
BEGIN 
	SELECT * FROM despesa d WHERE year(d.DataInicio) = year(data_despesa) AND month(d.DataInicio) = month(data_despesa);
END 
$$

CALL despesa_mes("2022-04-00");