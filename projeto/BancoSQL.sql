create schema oficina;
use oficina;

#drop schema oficina
#todo: criar um trigger pra cada funcionário cadastrado em um serviço, calcular a sua mão de obra 
CREATE TABLE Funcionario (
	Cpf INT(12) UNIQUE NOT NULL,
    Pnome VARCHAR(45) NOT NULL,
    Unome VARCHAR(45) NOT NULL,
    Ocupacao VARCHAR(45) NOT NULL,
    Salario DOUBLE NOT NULL,
    
    PRIMARY KEY (Cpf)
);

CREATE TABLE Cliente (
	IdCliente INT NOT NULL AUTO_INCREMENT,
    Contato VARCHAR(45), 
    Nome VARCHAR(100),
    PRIMARY KEY(IdCliente)
);

CREATE TABLE Veiculo (
	IdVeiculo INT NOT NULL auto_increment,
    IdCliente INT NOT NULL, 
    Placa VARCHAR(7) UNIQUE, 
	Modelo VARCHAR(45), 
    AnoFabricacao DATE, 
    Potencia DOUBLE,
    Servico_valor DOUBLE DEFAULT 0, 
    
    PRIMARY KEY (IdVeiculo),
	CONSTRAINT fk_cliente FOREIGN KEY (IdCliente) REFERENCES Cliente(IdCliente) ON UPDATE CASCADE 
);

CREATE TABLE Servico (
	IdServico INT NOT NULL AUTO_INCREMENT, 
    NomeServico VARCHAR(45), 
    Pago BOOLEAN DEFAULT FALSE,
    Orcamento DOUBLE, 
    IdVeiculo INT NOT NULL, 
    
    PRIMARY KEY (IdServico),
    CONSTRAINT fk_veiculo FOREIGN KEY (IdVeiculo) REFERENCES Veiculo(IdVeiculo) ON UPDATE CASCADE
);

CREATE TABLE Trabalha (
	Fcpf INT(12) NOT NULL,
    IdVeiculo INT NOT NULL, 
    
    CONSTRAINT fk_func_cpf foreign key (Fcpf) REFERENCES Funcionario(Cpf) ON UPDATE CASCADE,
    CONSTRAINT fk_veiculo_id foreign key (IdVeiculo) REFERENCES Servico(IdVeiculo) ON UPDATE CASCADE
);

CREATE TABLE Despesa (
	IdDespesa INT NOT NULL AUTO_INCREMENT,
    NomeDespesa VARCHAR(100) NOT NULL,
    Valor DOUBLE NOT NULL, 
    DataInicio DATE NOT NULL, 
    DataVencimento DATE,
    Pago BOOLEAN DEFAULT FALSE, 
    emissor INT,
    
    PRIMARY KEY (IdDespesa),
    FOREIGN KEY(emissor) REFERENCES Funcionario(Cpf)
);

#CRIAR UMA TABELA PARA A MÃO DE OBRA DE CADA VEÍCULO 
CREATE TABLE Mao_de_obra (
	IdVeiculo INT NOT NULL,
    Valor_mao_de_obra DOUBLE NOT NULL DEFAULT 0,
	
    CONSTRAINT fk_veiculo_mdb foreign key (IdVeiculo) REFERENCES Veiculo(IdVeiculo) ON UPDATE CASCADE
);

#triggers para o controle do valor de mão de obra e orçamento do serviço
DELIMITER $$
CREATE TRIGGER valor_servico_veiculo AFTER INSERT 
ON Servico
FOR EACH ROW 
BEGIN 
	UPDATE Veiculo 
    SET Servico_valor = Veiculo.Servico_valor + NEW.orcamento WHERE IdVeiculo=NEW.IdVeiculo;
END 
$$

DELIMITER $$
CREATE TRIGGER atualizar_valor_servico_veiculo AFTER UPDATE 
ON Servico
FOR EACH ROW 
BEGIN 
	UPDATE Veiculo 
    SET Servico_valor = Veiculo.Servico_valor - OLD.orcamento WHERE IdVeiculo=OLD.IdVeiculo;
    UPDATE Veiculo 
    SET Servico_valor = Veiculo.Servico_valor + NEW.orcamento WHERE IdVeiculo=NEW.IdVeiculo;
END 
$$

DELIMITER $$
CREATE TRIGGER apagar_valor_servico_veiculo AFTER delete 
ON Servico
FOR EACH ROW 
BEGIN 
	UPDATE Veiculo 
    SET Servico_valor = Veiculo.Servico_valor - OLD.orcamento WHERE IdVeiculo=OLD.IdVeiculo;
END 
$$

DELIMITER $$
CREATE TRIGGER mao_de_obra_veiculo AFTER INSERT 
ON mao_de_obra
FOR EACH ROW 
BEGIN 
	UPDATE Veiculo 
    SET Servico_valor = Veiculo.Servico_valor + NEW.valor_mao_de_obra WHERE IdVeiculo=NEW.IdVeiculo;
END 
$$

DELIMITER $$
CREATE TRIGGER apagar_mao_de_obra_veiculo AFTER DELETE
ON mao_de_obra
FOR EACH ROW 
BEGIN 
	UPDATE Veiculo 
    SET Servico_valor = Veiculo.Servico_valor - OLD.valor_mao_de_obra WHERE IdVeiculo=OLD.IdVeiculo;
END 
$$

DELIMITER $$
CREATE TRIGGER atualizar_mao_de_obra_veiculo AFTER UPDATE 
ON mao_de_obra
FOR EACH ROW 
BEGIN 
	UPDATE Veiculo 
    SET Servico_valor = Veiculo.Servico_valor - OLD.valor_mao_de_obra WHERE IdVeiculo=OLD.IdVeiculo;
    UPDATE Veiculo 
    SET Servico_valor = Veiculo.Servico_valor + NEW.valor_mao_de_obra WHERE IdVeiculo=NEW.IdVeiculo;
END 
$$

DELIMITER $$
CREATE FUNCTION salario(cpf INT(11))
RETURNS DOUBLE DETERMINISTIC 
BEGIN 
DECLARE Sal DOUBLE; 
    SELECT Salario FROM Funcionario f WHERE f.cpf = cpf INTO Sal;
	RETURN Sal;
END $$

#valor da mão de obra será definido por 10% do salário do funcionario
DELIMITER $$ 
CREATE FUNCTION calc_mao_obra (cpf INT(11))
RETURNS DOUBLE DETERMINISTIC 
BEGIN 
DECLARE valor_mao_de_obra DOUBLE;
DECLARE sal DOUBLE; 
SET sal = salario(cpf);
SET valor_mao_de_obra = sal * 0.10;
RETURN valor_mao_de_obra; 
END $$


DELIMITER $
CREATE TRIGGER valor_mao_de_obra AFTER INSERT 
ON Trabalha
FOR EACH ROW 
BEGIN 
DECLARE val_mao_de_obra DOUBLE;
	INSERT INTO Mao_de_obra (IdVeiculo, Valor_mao_de_obra) VALUES 
		(NEW.IdVeiculo, calc_mao_obra(NEW.Fcpf));
END$

CREATE VIEW vDespesas_a_pagar
AS 
SELECT NomeDespesa, Valor from despesa WHERE pago = FALSE;

CREATE VIEW vServicos_nao_pagos
AS 
select sum(s.orcamento) + m.valor_mao_de_obra 
as TOTAL, c.contato, c.nome 
from Servico s 
natural join Veiculo v 
natural join Cliente c 
natural join mao_de_obra m 
WHERE s.pago = FALSE 
GROUP BY v.idVeiculo 

