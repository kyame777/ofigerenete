-- ============================================================
-- SISTEMA DE GESTÃO DE OFICINA AUTOMÓVEL
-- Schema da base de dados (MySQL 8.0+)
-- ============================================================

CREATE DATABASE IF NOT EXISTS oficina_db
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE oficina_db;

-- ============================================================
-- 1. UTILIZADORES
-- Quatro perfis: cliente, mecanico, gestor, admin
-- ============================================================
CREATE TABLE utilizadores (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    nome            VARCHAR(120)    NOT NULL,
    email           VARCHAR(150)    NOT NULL UNIQUE,
    senha_hash      VARCHAR(255)    NOT NULL,
    telefone        VARCHAR(20),
    tipo            ENUM('cliente', 'mecanico', 'gestor', 'admin') NOT NULL,
    especialidade   VARCHAR(100)    NULL COMMENT 'Só para mecânicos: ex. motor, travões, elétrica',
    ativo           BOOLEAN         NOT NULL DEFAULT TRUE,
    criado_em       TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em   TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    INDEX idx_utilizadores_tipo (tipo),
    INDEX idx_utilizadores_email (email)
) ENGINE=InnoDB;

-- ============================================================
-- 2. CARROS
-- Cada carro pertence a um cliente
-- ============================================================
CREATE TABLE carros (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    cliente_id      INT             NOT NULL,
    marca           VARCHAR(60)     NOT NULL,
    modelo          VARCHAR(60)     NOT NULL,
    matricula       VARCHAR(20)     NOT NULL UNIQUE,
    ano             YEAR            NULL,
    cor             VARCHAR(30)     NULL,
    quilometragem   INT             NULL,
    criado_em       TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (cliente_id) REFERENCES utilizadores(id) ON DELETE CASCADE,
    INDEX idx_carros_cliente (cliente_id),
    INDEX idx_carros_matricula (matricula)
) ENGINE=InnoDB;

-- ============================================================
-- 3. ORDENS DE SERVIÇO
-- O núcleo do sistema: liga carro, cliente e mecânico
-- ============================================================
CREATE TABLE ordens_servico (
    id                  INT AUTO_INCREMENT PRIMARY KEY,
    carro_id            INT             NOT NULL,
    cliente_id          INT             NOT NULL,
    mecanico_id         INT             NULL COMMENT 'Atribuído pelo admin; pode ficar NULL até ser atribuído',
    titulo              VARCHAR(150)    NOT NULL COMMENT 'Resumo curto do problema',
    descricao           TEXT            NOT NULL COMMENT 'Descrição detalhada da situação a resolver',
    diagnostico         TEXT            NULL,
    estado              ENUM('aguardando', 'em_diagnostico', 'aguardando_aprovacao_orcamento',
                             'em_reparacao', 'pronto', 'entregue', 'cancelada')
                                         NOT NULL DEFAULT 'aguardando',
    prioridade          ENUM('baixa', 'normal', 'urgente') NOT NULL DEFAULT 'normal',
    custo_estimado       DECIMAL(10,2)  NULL,
    custo_final          DECIMAL(10,2)  NULL,
    data_entrada         DATE           NOT NULL,
    data_conclusao_prevista DATE        NULL,
    data_conclusao_real   TIMESTAMP     NULL,
    criado_em            TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em         TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (carro_id) REFERENCES carros(id) ON DELETE CASCADE,
    FOREIGN KEY (cliente_id) REFERENCES utilizadores(id) ON DELETE CASCADE,
    FOREIGN KEY (mecanico_id) REFERENCES utilizadores(id) ON DELETE SET NULL,
    INDEX idx_os_estado (estado),
    INDEX idx_os_mecanico (mecanico_id),
    INDEX idx_os_cliente (cliente_id)
) ENGINE=InnoDB;

-- ============================================================
-- 4. MENSAGENS (chat cliente <-> mecânico)
-- Cada mensagem pertence a uma ordem de serviço específica
-- ============================================================
CREATE TABLE mensagens (
    id                  INT AUTO_INCREMENT PRIMARY KEY,
    ordem_servico_id    INT             NOT NULL,
    remetente_id        INT             NOT NULL,
    conteudo            TEXT            NOT NULL,
    lida                BOOLEAN         NOT NULL DEFAULT FALSE,
    criado_em           TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (ordem_servico_id) REFERENCES ordens_servico(id) ON DELETE CASCADE,
    FOREIGN KEY (remetente_id) REFERENCES utilizadores(id) ON DELETE CASCADE,
    INDEX idx_mensagens_os (ordem_servico_id),
    INDEX idx_mensagens_lida (lida)
) ENGINE=InnoDB;

-- ============================================================
-- 5. NOTIFICAÇÕES
-- Disparadas por eventos: conclusão de trabalho, nova mensagem, etc.
-- ============================================================
CREATE TABLE notificacoes (
    id                  INT AUTO_INCREMENT PRIMARY KEY,
    utilizador_id       INT             NOT NULL COMMENT 'Quem recebe a notificação',
    ordem_servico_id    INT             NULL,
    tipo                ENUM('trabalho_concluido', 'nova_mensagem', 'ordem_atribuida', 'mudanca_estado', 'outro')
                                         NOT NULL,
    titulo              VARCHAR(150)    NOT NULL,
    mensagem            VARCHAR(255)    NOT NULL,
    lida                BOOLEAN         NOT NULL DEFAULT FALSE,
    criado_em           TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (utilizador_id) REFERENCES utilizadores(id) ON DELETE CASCADE,
    FOREIGN KEY (ordem_servico_id) REFERENCES ordens_servico(id) ON DELETE CASCADE,
    INDEX idx_notif_utilizador (utilizador_id, lida)
) ENGINE=InnoDB;

-- ============================================================
-- 6. HISTÓRICO DE ESTADOS (opcional, mas ótimo para a defesa)
-- Regista cada mudança de estado de uma ordem de serviço
-- ============================================================
CREATE TABLE historico_estados (
    id                  INT AUTO_INCREMENT PRIMARY KEY,
    ordem_servico_id    INT             NOT NULL,
    estado_anterior     VARCHAR(40)     NULL,
    estado_novo         VARCHAR(40)     NOT NULL,
    alterado_por        INT             NOT NULL,
    criado_em           TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (ordem_servico_id) REFERENCES ordens_servico(id) ON DELETE CASCADE,
    FOREIGN KEY (alterado_por) REFERENCES utilizadores(id) ON DELETE CASCADE,
    INDEX idx_historico_os (ordem_servico_id)
) ENGINE=InnoDB;

-- ============================================================
-- DADOS DE EXEMPLO (para testares o sistema durante o desenvolvimento)
-- ============================================================

-- Admin
INSERT INTO utilizadores (nome, email, senha_hash, tipo) VALUES
('Kyame Lourenço', 'admin@oficina.ao', '$2b$10$exemplo_hash_substituir', 'admin');

-- Mecânico
INSERT INTO utilizadores (nome, email, senha_hash, telefone, tipo, especialidade) VALUES
('João Mecânico', 'joao.mecanico@oficina.ao', '$2b$10$exemplo_hash_substituir', '923000111', 'mecanico', 'Motor e travões');

-- Cliente
INSERT INTO utilizadores (nome, email, senha_hash, telefone, tipo) VALUES
('Maria Cliente', 'maria.cliente@gmail.com', '$2b$10$exemplo_hash_substituir', '924000222', 'cliente');

-- Carro do cliente
INSERT INTO carros (cliente_id, marca, modelo, matricula, ano, cor) VALUES
(3, 'Toyota', 'Corolla', 'LD-45-67-AA', 2018, 'Prata');

-- Ordem de serviço
INSERT INTO ordens_servico (carro_id, cliente_id, mecanico_id, titulo, descricao, estado, data_entrada) VALUES
(1, 3, 2, 'Ruído no motor', 'Cliente reporta ruído metálico ao acelerar.', 'em_reparacao', CURDATE());
