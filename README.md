# ✨ Aura Study

Plataforma educativa social com **Inteligência Artificial**, construída em **Flutter** + **Firebase**. Inspirada na Knowunity, Notion, Duolingo e ChatGPT.

> Estuda. Partilha. Evolui.

---

## 🧱 Stack

- **Flutter 3.19+** (Material 3, vibe iOS)
- **Provider** (state management)
- **Firebase** — Auth, Firestore, Storage, Messaging
- **Google Sign-In**
- **OpenAI API** (Aura AI) — com fallback "demo" sem chave
- **Google Fonts (Inter)**, **flutter_markdown**, **table_calendar**, **fl_chart**

## 🎨 Paleta

| Cor | Hex |
| --- | --- |
| Roxo principal | `#7B61FF` |
| Roxo escuro | `#5B45D6` |
| Preto BG | `#0E0B14` |
| Branco BG | `#F7F7FB` |

## 📁 Estrutura

```
lib/
├── main.dart              # entry point
├── app.dart               # MaterialApp + tema + rotas
├── firebase_options.dart  # placeholder (gerar com flutterfire)
├── models/                # User, Post, ChatMessage
├── providers/             # Auth, Theme, Chat, Feed
├── services/              # Auth, Firestore, Storage, AI, Notifications
├── screens/
│   ├── splash_screen.dart
│   ├── main_navigation.dart
│   ├── auth/              # login, register, forgot
│   ├── home/              # feed Knowunity-style
│   ├── chat/              # Aura AI (ChatGPT-style)
│   ├── upload/            # PDF / Imagem / Resumo
│   ├── study/             # pomodoro, calendário, hub
│   ├── profile/           # perfil + XP + ranking
│   └── settings/          # tema escuro, conta
├── widgets/               # PostCard, ChatBubble, SubjectChip, etc.
└── utils/                 # theme, constants, routes
```

## 🚀 Como correr

### 1. Instalar dependências
```bash
flutter pub get
```

### 2. Configurar Firebase (opcional para demo)

A app **funciona sem Firebase** em modo convidado/demo. Para ativar Auth real, Firestore e Storage:

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

Isto gera o `lib/firebase_options.dart` real (substituindo o placeholder).

### 3. Ligar a IA real (Aura AI) ✨

A Aura AI suporta **Gemini** (recomendado, **gratuito**) e **OpenAI**. A configuração faz-se **dentro da app** — não precisas de mexer em código nem de variáveis de ambiente.

#### Opção A — Gemini (grátis, recomendada)

1. Vai a **[aistudio.google.com/apikey](https://aistudio.google.com/apikey)**
2. Faz login com Google → **"Create API key"** → escolhe um projeto (ou cria um) → **copia a chave** (começa por `AIza…`)
3. Na app, abre **Definições** (ícone ⚙️ no topo do Chat ou no Perfil)
4. Em **Aura AI**, escolhe `Gemini (free)` e cola a chave
5. Clica **"Guardar chave"** → aparece um ✅ verde
6. Volta ao Chat — agora a IA responde a **qualquer pergunta**

#### Opção B — OpenAI (paga, ~$0.15 por 1M tokens com `gpt-4o-mini`)

1. Vai a **[platform.openai.com/api-keys](https://platform.openai.com/api-keys)**
2. **Create new secret key** → copia (`sk-…`)
3. Na app: **Definições → Aura AI → OpenAI** → cola → guardar

A chave fica guardada **só no teu dispositivo** (`SharedPreferences`).

#### Como interliga internamente

```
[ChatScreen] → ChatProvider.send(text)
                 ↓
        AiService.sendMessage(history, provider, key)
                 ↓
   ┌─────────────┴─────────────┐
   │                           │
Gemini API                  OpenAI API
(generativelanguage…)       (api.openai.com/v1/chat)
   │                           │
   └─→ resposta em markdown ←──┘
                 ↓
        ChatBubble (renderiza com flutter_markdown)
```

A `SettingsProvider` notifica o `ChatProvider` via `ChangeNotifierProxyProvider` em `main.dart`, por isso ao guardares a chave o chat passa imediatamente a usá-la — **sem reinício**.

### 4. Lançar a app

```bash
flutter run
```

## ✨ Funcionalidades

- ✅ Splash animado
- ✅ Login / Registo / Recuperar password / Login Google
- ✅ Feed estilo Knowunity (cards, likes, comentários, pesquisa)
- ✅ Filtros por disciplina (chips)
- ✅ **Aura AI** — chat com IA estilo ChatGPT (markdown, sugestões rápidas, animação de typing)
- ✅ Upload de PDFs / Imagens / Resumos com categorias
- ✅ Pomodoro 25/5 com progress circular
- ✅ Calendário de tarefas
- ✅ Estatísticas de produtividade
- ✅ Perfil com XP, nível, seguidores, favoritos
- ✅ Dark mode
- ✅ Notificações push (FCM) + locais
- ✅ Bottom Navigation Bar custom

## 🧠 Aura AI

O cérebro da app está em `lib/services/ai_service.dart`. Suporta OpenAI (`gpt-4o-mini`) e tem um modo demo que funciona offline para teste imediato.

Para trocar por Gemini, edita `AiService.sendMessage` apontando para o endpoint da Google AI.

## 📦 Próximos passos

- [ ] Persistência local de conversas (Hive/Isar)
- [ ] Streaming de tokens da OpenAI (SSE)
- [ ] Ranking real de utilizadores via Cloud Functions
- [ ] OCR de fotos de apontamentos
- [ ] Gamificação (badges, missões diárias)

## 🛡️ Boas práticas

- Não comites chaves de API no repositório — usa `--dart-define` ou variáveis de ambiente.
- Configura **Firestore Security Rules** antes de ir para produção.
- Ativa **App Check** no Firebase para evitar abuso.

---

Made with 💜 by Aura Study.
# aura-study
