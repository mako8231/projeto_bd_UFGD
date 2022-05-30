INSERT INTO Funcionario(Cpf, Pnome, Unome, Ocupacao, Salario) VALUES 
(1111111111, "João", "Silva", "Mecânico", 800.00),
(2111222211, "João", "Miguel", "Mecânico", 800.00),
(1111222211, "André", "Afonso", "Mecânico", 800.00),
(1111111112, "Maria", "Souza", "Atendente", 900.00);

INSERT INTO Cliente(Contato, Nome) VALUES 
("(67) 99955-2321", "Rodrigo Freitas"),
("(67) 99123-2431", "Andreia Alves"),
("(67) 99995-2320", "Andre Luiz"),
("(67) 98195-2321", "Amanda Patrícia"),
("(67) 97795-2320", "Luiz Silva");


#obviamente os modelos n condizem com a realidade, mexer nisso depois 
INSERT INTO Veiculo(IdCliente, Placa, Modelo, AnoFabricacao, Potencia) VALUES 
#potencia é medida em Horse Power 
(1, "BRF1234", "GolG2", "1999-12-19", 100.00),
(1, "ALF1334", "Vectra 76", "2003-12-19", 100.00),
(3, "OIE1443", "Subaru WRX 2022", "2022-01-01", 150), 
(2, "BLF1334", "Cruzer 87", "2012-12-19", 100.00),
(4, "JLR7777", "Honda TR42", "2014-12-19", 132.12),
(5, "ALR7237", "FIAT UNO", "2002-12-19", 100);

INSERT INTO Servico(NomeServico, Orcamento, IdVeiculo) VALUES 
("Troca do freio dianteiro", 400.00, 1),
("Troca do Cabeçote", 1200.00, 1),
("Troca do Pneu", 300.50, 2),
("Troca da Direção", 500.20, 3),
("Ajuste no câmbio manual", 220.20, 4),
("Troca de óleo", 190.20, 2),
("Ajuste da cilindrada", 150.20, 3),
("Troca de peça do motor", 720.20, 1),
("Manutenção do volante", 150.20, 2);

INSERT INTO Trabalha (Fcpf, IdVeiculo) VALUES 
	(1111111111, 1),
    (2111222211, 2),
    (1111222211, 3),
    (1111222211, 4),
    (1111111112, 4);
    
INSERT INTO Despesa (NomeDespesa, Valor, DataInicio, DataVencimento, Emissor, Pago) VALUES 
	("Compra de pneus", 270, NOW(), NOW(), 1111111111, TRUE),
    ("Compra velas de motor", 120, NOW(), "2022-07-23", 1111222211, false),
    ("Salgadinhos do seu zé", 7.00, NOW(), NOW(), 1111111111, true),
	("Compra da tampa do volante de carro", 120.00 , NOW(), NOW(), 1111111111, true),
	("Conta de Energia", 890.00, NOW(), "2022-08-31", NULL, false);
	
select * from trabalha