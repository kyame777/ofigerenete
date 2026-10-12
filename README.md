# Frontend — Sistema de Gestão de Oficina

React + Vite + React Router + Socket.io-client.

## 1. Instalação

```bash
cd oficina-frontend
npm install
```

## 2. Configurar a ligação à API

```bash
cp .env.example .env
```

Confirma que `VITE_API_URL` aponta para o backend (por defeito `http://localhost:3000`).

## 3. Arrancar

```bash
npm run dev
```

Abre `http://localhost:5173`. Certifica-te de que o **backend já está a correr**
(ver README do `oficina-backend`), senão o login e os pedidos vão falhar.

## Estrutura

```
src/
  api/axios.js          → instância do axios com token automático
  context/AuthContext    → login, registo, logout, utilizador atual
  context/SocketContext  → ligação Socket.io partilhada
  components/            → Layout, sino de notificações, rota protegida
  pages/
    Login.jsx
    Register.jsx
    Dashboard.jsx         → resumo de ordens por estado
    Carros.jsx            → listar/cadastrar carros
    Ordens.jsx             → listar/criar ordens de serviço
    OrdemDetalhe.jsx       → detalhe da ordem + chat em tempo real + mudar estado
```

## O que já funciona

- Registo e login com os 3 perfis (cliente, mecânico, admin)
- Cadastro e listagem de carros
- Criar ordem de serviço (cliente) e mudar o estado (mecânico/admin)
- **Chat em tempo real** por ordem de serviço, com indicador "a escrever..."
- **Notificações em tempo real** (sino no topo, atualiza sozinho quando o
  backend envia um evento — ex: quando o mecânico marca "concluída")

## Próximos passos sugeridos

- Ecrã de admin para atribuir mecânico a uma ordem (falta o endpoint
  `GET /api/utilizadores?tipo=mecanico` no backend para listar os mecânicos —
  é simples de adicionar seguindo o padrão das outras rotas)
- Upload de fotos do problema
- Página de histórico de estados de uma ordem
