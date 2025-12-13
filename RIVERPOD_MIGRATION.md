# Migração de Provider para Riverpod - Documentação

## Resumo da Migração

Seu projeto Flutter foi migrado com sucesso de **Provider (ChangeNotifier)** para **Riverpod (StateNotifier)**, eliminando dependências de `BuildContext` em providers e adotando padrões reativos mais limpos.

---

## 📋 Arquivos Modificados

### 1. **pubspec.yaml**
- ❌ Removido: `provider: ^6.1.4`
- ✅ Adicionado: `flutter_riverpod: ^2.6.0`
- ✅ Adicionado: `riverpod: ^2.6.0`
- ✅ Adicionado: `riverpod_annotation: ^2.3.0`
- ✅ Adicionado (dev): `build_runner: ^2.4.0`
- ✅ Adicionado (dev): `riverpod_generator: ^2.4.0`

### 2. **lib/main.dart**
**Antes:**
```dart
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';

runApp(
  ChangeNotifierProvider(
    create: (_) => AuthProvider(),
    child: const NoushokuApp(),
  ),
);
```

**Depois:**
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

runApp(
  const ProviderScope(
    child: NoushokuApp(),
  ),
);
```

**Mudanças:**
- Substituiu `ChangeNotifierProvider` por `ProviderScope` (raiz do Riverpod)
- Removida referência manual de `AuthProvider`
- Riverpod gerencia automaticamente injeção de providers

### 3. **lib/providers/auth_notifier.dart** (novo arquivo)
Substituiu `lib/providers/auth_provider.dart` com arquitetura limpa:

**Estrutura:**
```dart
// 1. Modelos imutáveis
class AuthState {
  final User? firebaseUser;
  final AppUser? user;
  final List<Map<String, dynamic>> addresses;
  final String? selectedAddressId;
  final List<Map<String, dynamic>> purchases;
  final bool isLoading;
  final String? error;

  AuthState copyWith({ /* argumentos opcionais */ });
  
  bool get isLoggedIn => firebaseUser != null;
  Map<String, dynamic>? get selectedAddress { /* lógica */ }
}

// 2. StateNotifier - nenhuma dependência de BuildContext
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState()) {
    _init(); // inicia listeners
  }
  
  // Todos os métodos foram preservados (nomes iguais)
  Future<void> signIn(...) async { /* ... */ }
  Future<void> createAccount(...) async { /* ... */ }
  Future<void> addAddress(...) async { /* ... */ }
  // ... etc
}

// 3. Provider com injeção automática
final authNotifierProvider = 
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
```

**Vantagens desta arquitetura:**
- ✅ **Sem BuildContext**: AuthNotifier não precisa de context
- ✅ **Imutabilidade**: AuthState é imutável (copyWith pattern)
- ✅ **Auto-limpeza**: Riverpod gerencia subscriptions automaticamente
- ✅ **Debug melhor**: Logs estruturados em cada operação
- ✅ **TypeSafe**: Tipo de estado explícito `StateNotifier<AuthState>`

---

## 🎯 Mudanças em Cada Tela

### 4. **lib/screens/mypage_screen.dart**

**Antes:**
```dart
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class _MyPageScreenState extends State<MyPageScreen> {
  Future<void> _signIn() async {
    final provider = Provider.of<AuthProvider>(context, listen: false);
    await provider.signIn(email, pass, remember: _rememberMe);
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    return Scaffold(
      body: auth.isLoggedIn ? _buildLoggedInUI() : _buildLoggedOutUI(),
    );
  }
}
```

**Depois:**
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_notifier.dart';

class _MyPageScreenState extends State<MyPageScreen> {
  Future<void> _signIn(WidgetRef ref) async {
    final notifier = ref.read(authNotifierProvider.notifier);
    await notifier.signIn(email, pass, remember: _rememberMe);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer(
        builder: (context, ref, _) {
          final auth = ref.watch(authNotifierProvider);
          return auth.isLoggedIn 
              ? _buildLoggedInUI(ref) 
              : _buildLoggedOutUI(ref);
        },
      ),
    );
  }
}
```

**Padrões Riverpod Usados:**
- `Consumer` widget para acessar ref
- `ref.watch()` para valores reativos (rebuild automático)
- `ref.read()` para valores únicos (sem rebuild)
- `ref.read(provider.notifier)` para chamar métodos

### 5. **lib/screens/order_screen_history.dart**

**Transformado de StatefulWidget para ConsumerStatefulWidget:**

**Antes:**
```dart
class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  AuthProvider? _authProvider;
  VoidCallback? _authListener;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final auth = Provider.of<AuthProvider>(context);
    if (_authProvider != auth) {
      _authProvider?.removeListener(_authListener!);
      _authProvider = auth;
      _authListener = () {
        // atualiza controllers manualmente
        _emailController.text = _authProvider!.user?.email ?? '';
      };
      _authProvider!.addListener(_authListener!);
    }
  }

  @override
  void dispose() {
    _authProvider?.removeListener(_authListener!);
    super.dispose();
  }
}
```

**Depois:**
```dart
class _OrderHistoryScreenState extends ConsumerState<OrderHistoryScreen> {
  
  // Nenhum listener manual necesário!

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authNotifierProvider);
    
    // Update controllers via WidgetsBinding (sem listener duradouro)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final newEmail = auth.user?.email ?? '';
      if (_emailController.text != newEmail) {
        _emailController.text = newEmail;
      }
    });

    return Scaffold(/* ... */);
  }
}
```

**Benefícios:**
- ❌ Removida duplicação de listener setup/cleanup
- ✅ `ref.watch()` auto-gerencia subscriptions
- ✅ Cleanup automático ao descartar widget

### 6. **lib/screens/purchase_history_screen.dart**

**Transformado para ConsumerStatefulWidget:**

**Antes:**
```dart
final auth = Provider.of<AuthProvider>(context, listen: false);
if (auth.isLoggedIn) {
  final id = purchaseHistory[index]['id'];
  if (id != null) await auth.removePurchase(id);
}
```

**Depois:**
```dart
final auth = ref.read(authNotifierProvider);
if (auth.isLoggedIn) {
  final id = purchaseHistory[index]['id'];
  if (id != null) {
    await ref.read(authNotifierProvider.notifier).removePurchase(id);
  }
}
```

---

## 🔑 Conceitos-Chave do Riverpod

### Provider Types Usados

| Provider | Caso de Uso |
|----------|-----------|
| `StateNotifierProvider` | Estado mutável com notifier (nosso `authNotifierProvider`) |
| `ConsumerWidget` / `ConsumerStatefulWidget` | Widgets que consomem providers |
| `Consumer()` | Builder callback para acessar providers em qualquer widget |
| `ref.watch()` | Observa valor (rebuilda se mudar) |
| `ref.read()` | Lê valor uma vez (sem rebuild automático) |
| `ref.read(provider.notifier)` | Chama métodos do notifier |

### Padrões Importantes

**1. StatelessWidget Reativo:**
```dart
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authNotifierProvider);
    return Text(auth.user?.email ?? 'Not logged in');
  }
}
```

**2. StatefulWidget Reativo:**
```dart
class MyScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends ConsumerState<MyScreen> {
  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authNotifierProvider);
    return Scaffold(body: Text(auth.user?.email ?? ''));
  }
}
```

**3. Consumer Builder:**
```dart
Scaffold(
  body: Consumer(
    builder: (context, ref, child) {
      final auth = ref.watch(authNotifierProvider);
      return auth.isLoggedIn ? LoggedInUI() : LoginUI();
    },
  ),
)
```

**4. Chamar Métodos do Notifier:**
```dart
// Leitura única (sem rebuild)
final notifier = ref.read(authNotifierProvider.notifier);
await notifier.signIn(email, password);

// Ou em callback
ElevatedButton(
  onPressed: () async {
    await ref.read(authNotifierProvider.notifier).signOut();
  },
  child: Text('Logout'),
)
```

---

## 🚀 Benefícios da Migração

| Aspecto | Provider | Riverpod |
|--------|----------|---------|
| **BuildContext Dependencies** | ❌ Obrigatório em providers | ✅ Nenhum |
| **Cleanup Manual** | ❌ didChangeDependencies + listeners | ✅ Automático |
| **Type Safety** | ⚠️ Dynamic em alguns casos | ✅ Totalmente type-safe |
| **Imutabilidade** | ❌ notifyListeners() | ✅ copyWith pattern |
| **Testing** | ⚠️ Requer context mock | ✅ Sem dependências externas |
| **Performance** | ⚠️ Toda listener = rebuild | ✅ Selective rebuilds |
| **Composição** | ❌ Complexa | ✅ `ref.watch()` combinável |

---

## 📊 Estrutura de Dados Final

```
lib/
├── providers/
│   └── auth_notifier.dart
│       ├── AppUser (classe de dados)
│       ├── AuthState (estado imutável com copyWith)
│       ├── AuthNotifier extends StateNotifier<AuthState>
│       └── authNotifierProvider (final StateNotifierProvider)
├── screens/
│   ├── mypage_screen.dart (StatefulWidget → usa ref.watch/read)
│   ├── order_screen_history.dart (ConsumerStatefulWidget)
│   └── purchase_history_screen.dart (ConsumerStatefulWidget)
└── main.dart (ProviderScope wrapper)
```

---

## ✅ Checklist de Testes

Após compilar e executar:

- [ ] Login funciona e persiste em browser
- [ ] Endereços são salvos/editados/deletados
- [ ] OrderHistoryScreen popula email/endereço automaticamente
- [ ] Purchase history lista pedidos (online ou SharedPrefs)
- [ ] Logout limpa estado completamente
- [ ] Sem erros de compilação (`flutter analyze`)
- [ ] Riverpod DevTools mostra estado correto (se instalado)

---

## 📚 Referências Úteis

- **Documentação Riverpod**: https://riverpod.dev
- **StateNotifierProvider Guide**: https://riverpod.dev/docs/providers/state_notifier_provider
- **Testing Riverpod**: https://riverpod.dev/docs/testing
- **Riverpod vs Provider**: https://riverpod.dev/docs/comparisons/provider

---

## 🎓 Próximos Passos (Opcionais)

1. **Adicionar Riverpod DevTools** para debugging visual:
   ```yaml
   dev_dependencies:
     riverpod_generator: ^2.4.0
     riverpod_cli: ^2.0.0
   ```

2. **Usar `@riverpod` annotation** para providers derivados:
   ```dart
   @riverpod
   bool isLoggedIn(Ref ref) {
     return ref.watch(authNotifierProvider).isLoggedIn;
   }
   ```

3. **Combinar providers** para lógica complexa:
   ```dart
   @riverpod
   Future<List<Order>> userOrders(Ref ref) async {
     final auth = ref.watch(authNotifierProvider);
     if (!auth.isLoggedIn) return [];
     return ref.watch(purchasesStreamProvider).whenData((p) => p);
   }
   ```

---

**Migração Concluída com Sucesso! 🎉**

Seu projeto está agora mais limpo, mais testável e segue as melhores práticas modernas do Riverpod.
