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
    AnoFabricacao DATETIME, 
    Potencia DOUBLE,
    
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
    DataInicio DATETIME NOT NULL, 
    DataVencimento DATETIME,
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

INSERT INTO Funcionario(Cpf, Pnome, Unome, Ocupacao, Salario) VALUES 
(1111111111, "João", "Silva", "Mecânico", 800.00),
(2111222211, "João", "Miguel", "Mecânico", 800.00),
(1111222211, "André", "Afonso", "Mecânico", 800.00),
(1111111112, "Maria", "Souza", "Atendente", 900.00);

INSERT INTO Cliente(Contato, Nome) VALUES 
("(67) 99955-2321", "Rodrigo Freitas"),
("(67) 99123-2431", "Andreia Alves"),
("(67) 99995-2320", "Andre Luiz");


#obviamente os modelos n condizem com a realidade, mexer nisso depois 
INSERT INTO Veiculo(IdCliente, Placa, Modelo, AnoFabricacao, Potencia) VALUES 
#potencia é medida em Horse Power 
(1, "BRF1234", "GolG2", "1999-12-19", 100.00),
(1, "ALF1334", "Vectra 76", "2003-12-19", 100.00),
(3, "OIE1443", "Subaru WRX 2022", "2022-01-01", 150), 
(2, "BLF1334", "Cruzer 87", "2012-12-19", 100.00);


INSERT INTO Servico(NomeServico, Orcamento, IdVeiculo) VALUES 
("Troca do freio dianteiro", 400.00, 1),
("Troca do Cabeçote", 1200.00, 1),
("Troca do Pneu", 300.50, 2),
("Troca da Direção", 500.20, 3),
("Manutenção do freio dianteiro", 350.20, 4);

INSERT INTO Trabalha (Fcpf, IdVeiculo) VALUES 
	(1111111111, 1),
    (2111222211, 2),
    (1111222211, 3),
    (1111222211, 4),
    (1111111112, 4);
    
INSERT INTO Despesa (NomeDespesa, Valor, DataInicio, DataVencimento, Emissor, Pago) VALUES 
	("Compra de pneus", 270, NOW(), NOW(), 1111111111, TRUE),
    ("Compra velas de motor", 120, NOW(), "2022-07-23", 1111222211, false),
    ("Salgadinhos do seu zé", 7.00, NOW(), NOW(), 1111111111, true);



select * from Servico s natural join Veiculo v natural join Cliente c 
