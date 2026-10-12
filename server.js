// server.js
require('./config/env');
const express = require('express');
const cors = require('cors');
const http = require('http');
const { Server } = require('socket.io');

const { testarLigacao } = require('./config/db');
const { configurarSocket } = require('./sockets/chatSocket');

const authRoutes = require('./routes/auth.routes');
const carrosRoutes = require('./routes/carros.routes');
const ordensRoutes = require('./routes/ordens.routes');
const ordensFase2Routes = require('./routes/ordens.phase2.routes');
const mensagensRoutes = require('./routes/mensagens.routes');
const notificacoesRoutes = require('./routes/notificacoes.routes');
const marcacoesRoutes = require('./routes/marcacoes.routes');
const stockRoutes = require('./routes/stock.routes');
const utilizadoresRoutes = require('./routes/utilizadores.routes');
const faturasRoutes = require('./routes/faturas.routes');
const relatoriosRoutes = require('./routes/relatorios.routes');

const app = express();
const servidor = http.createServer(app);

const io = new Server(servidor, {
  cors: {
    origin: process.env.FRONTEND_URL || '*',
    methods: ['GET', 'POST'],
  },
});

// Torna o "io" acessível dentro das rotas via req.app.get('io')
// — é assim que, por exemplo, a rota de concluir uma ordem consegue
// enviar a notificação em tempo real.
app.set('io', io);

app.use(cors());
app.use(express.json());

// ----------------------------------------------------------------
// Rotas
// ----------------------------------------------------------------
app.get('/', (req, res) => {
  res.json({ mensagem: 'API da Oficina — a funcionar' });
});

app.use('/api/auth', authRoutes);
app.use('/api/carros', carrosRoutes);
app.use('/api/ordens', ordensFase2Routes);
app.use('/api/ordens', ordensRoutes);
app.use('/api/marcacoes', marcacoesRoutes);
app.use('/api/stock', stockRoutes);
app.use('/api/utilizadores', utilizadoresRoutes);
app.use('/api/faturas', faturasRoutes);
app.use('/api/relatorios', relatoriosRoutes);
app.use('/api/mensagens', mensagensRoutes);
app.use('/api/notificacoes', notificacoesRoutes);

// Rota "apanha tudo" para pedidos a endpoints que não existem
app.use((req, res) => {
  res.status(404).json({ erro: 'Rota não encontrada.' });
});

// Tratamento de erros não capturados
app.use((erro, req, res, next) => {
  console.error('Erro não tratado:', erro);
  res.status(500).json({ erro: 'Erro interno do servidor.' });
});

// ----------------------------------------------------------------
// Socket.io
// ----------------------------------------------------------------
configurarSocket(io);

// ----------------------------------------------------------------
// Arranque do servidor
// ----------------------------------------------------------------
const PORTA = process.env.PORT || 3000;

servidor.listen(PORTA, async () => {
  console.log(`Servidor a correr em http://localhost:${PORTA}`);
  await testarLigacao();
});
