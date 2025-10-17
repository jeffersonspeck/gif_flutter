GIF Flutter

Um aplicativo Flutter para buscar, visualizar e favoritar GIFs usando a API do Giphy.
Permite também acompanhar histórico de pesquisas e gerenciar favoritos.

Funcionalidades

Buscar GIFs por palavra-chave (tags).

Visualizar GIFs aleatórios com auto-shuffle.

Favoritar GIFs e remover favoritos.

Histórico das pesquisas recentes.

Controle de classificação (G, PG, PG-13, R).

Interface responsiva para diferentes tamanhos de tela.

Screenshots

(adicione capturas de tela aqui se desejar)

Tecnologias e Dependências

Flutter

Provider (gerenciamento de estado)

SQFlite (armazenamento local de favoritos, histórico e preferências)

HTTP (requisições à API do Giphy)

SharedPreferences (cache do random_id)

Instalação

Clone o repositório:

git clone <URL_DO_REPOSITORIO>
cd gif_flutter


Instale as dependências:

flutter pub get


Execute o app:

flutter run

Estrutura de Pastas
lib/
├─ core/                  # Constantes e temas
├─ data/
│  ├─ controllers/        # Controladores (ex: GifsController)
│  ├─ models/             # Modelos de dados (ex: GiphyGif)
│  └─ services/           # Serviços (API, banco de dados)
├─ features/
│  └─ gifs/
│     ├─ screens/         # Páginas do app (random, search, favorites, history)
│     └─ widgets/         # Widgets reutilizáveis (grid, tile, display)
└─ main.dart              # Entrada do app

Uso do Provider

O app usa Provider para gerenciamento de estado:

GifsController é o provider principal.

Disponibiliza dados como GIFs, favoritos e histórico para todas as páginas.

Atualiza automaticamente os widgets quando os dados mudam.

Exemplo:

final controller = context.watch<GifsController>(); // observa mudanças
final controller = context.read<GifsController>();  // apenas acessa dados

Configuração da API do Giphy

No arquivo main.dart:

GifsController(
  GiphyService(apiKey: '<SUA_API_KEY_AQUI>'),
)


Substitua <SUA_API_KEY_AQUI> pela sua chave da API do Giphy.

Páginas Principais

Random GIF Page: Mostra GIF aleatório com auto-shuffle.

Search GIF Page: Busca GIFs por tags e filtra por classificação.

Favorites Page: Lista de GIFs favoritados.

History Page: Histórico das pesquisas recentes.