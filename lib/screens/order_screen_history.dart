import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/order_history.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import 'home_screen.dart';
import 'orders_screen.dart';
import 'mypage_screen.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_stripe/flutter_stripe.dart' as stripe;
import 'dart:html' as html;

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  int _selectedBottomIndex = 2;
  static int _orderCounter = 0;

  // controllers for text fields
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _customMessageController =
      TextEditingController();
  final TextEditingController _recipientController = TextEditingController();

  // login state (local via SharedPreferences)
  bool isLoggedIn = false;
  String loggedEmail = '';
  String loggedAddress = '';

  // gift / message
  bool isGift = false;
  int? selectedMessage;
  String? selectedSeason = '春';

  bool _processingPayment = false;

  static const Color green = Color(0xFF307A59);
  static const Color scaffoldBg = Color(0xFFE5E9EC);

  @override
  void initState() {
    super.initState();
    _loadLoginState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _addressController.dispose();
    _customMessageController.dispose();
    _recipientController.dispose();
    super.dispose();
  }

  Future<void> _loadLoginState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      loggedEmail = prefs.getString('userEmail') ?? '';
      loggedAddress = prefs.getString('userAddress') ?? '';
    });
  }

  double getTotal() {
    return orderHistory.fold(
      0,
      (sum, item) => sum + item.item.price * item.quantity,
    );
  }

  bool _isNonEmpty(String? s) => s != null && s.trim().isNotEmpty;

  bool canCheckout() {
    if (orderHistory.isEmpty) return false;
    if (isLoggedIn) return orderHistory.isNotEmpty;

    // Para usuários não logados, basta email e endereço preenchidos
    final emailOk = _isNonEmpty(_emailController.text);
    final addressOk = _isNonEmpty(_addressController.text);

    return emailOk && addressOk;
  }

  Future<void> _checkoutAll() async {
    if (orderHistory.isEmpty) return;

    final String effectiveEmail = isLoggedIn
        ? loggedEmail
        : _emailController.text.trim();
    final String effectiveAddress = isLoggedIn
        ? loggedAddress
        : _addressController.text.trim();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final double totalGeral = getTotal();
        final String recipient = _recipientController.text.trim();

        String? giftMsg;
        if (isGift) {
          switch (selectedMessage) {
            case 1:
              giftMsg = _customMessageController.text; // 自由に入力
              break;
            case 2:
              giftMsg =
                  '「いつも大変お世話になっております。日頃の感謝の気持ちを込めて、心ばかりの品をお贈りさせていただきます。これからもどうぞよろしくお願いいたします。」';
              break;
            case 3:
              giftMsg =
                  '「いつもお世話になっております。日頃の感謝を込めて、ささやかですが贈らせていただきます。お口に合えば嬉しいです。」';
              break;
            case 4:
              giftMsg = '「いつもありがとうございます。感謝の気持ちです。喜んでいただけたら嬉しいです。」';
              break;
            case 5:
              giftMsg =
                  '「${selectedSeason ?? '〇'}の候、いつもお世話になっております。日頃の感謝を込めて、心ばかりの品をお届けいたします。」';
              break;
            default:
              giftMsg = null;
          }
        }

        return Dialog(
          backgroundColor: scaffoldBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: SizedBox(
            width: double.maxFinite,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '注文内容の確認',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: green,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 200),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: orderHistory.length,
                      separatorBuilder: (_, __) => const Divider(color: green),
                      itemBuilder: (_, index) {
                        final o = orderHistory[index];
                        final subtotal = o.item.price * o.quantity;
                        return ListTile(
                          title: Text(
                            o.item.labelKey,
                            style: const TextStyle(color: green),
                          ),
                          subtitle: Text(
                            '¥${o.item.price.toStringAsFixed(0)} × ${o.quantity}',
                            style: const TextStyle(color: green),
                          ),
                          trailing: Text(
                            '¥${subtotal.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: green,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const Divider(thickness: 2, color: green),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '合計: ¥${totalGeral.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: green,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'メールアドレス: $effectiveEmail',
                          style: const TextStyle(color: green),
                        ),
                        Text(
                          '配送先住所: $effectiveAddress',
                          style: const TextStyle(color: green),
                        ),
                        if (isGift)
                          Text(
                            '宛先名: ${recipient.isNotEmpty ? recipient : '（未入力）'}',
                            style: const TextStyle(color: green),
                          ),
                      ],
                    ),
                  ),
                  if (giftMsg != null && giftMsg.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'ギフトメッセージ:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: green,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        giftMsg,
                        style: const TextStyle(color: green),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(ctx).pop(false),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: green),
                            foregroundColor: green,
                          ),
                          child: const Text('戻る'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(ctx).pop(true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: green,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('確認'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (confirmed != true) return;

    final int amount = getTotal().round();

    setState(() => _processingPayment = true);
    try {
      if (kIsWeb) {
        final backendUrl = Uri.parse(
          'https://createcheckoutsession-npxjhuxoaq-uc.a.run.app/create-checkout-session',
        );

        final resp = await http.post(
          backendUrl,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'amount': amount,
            'currency': 'jpy',
            'email': effectiveEmail,
          }),
        );

        if (resp.statusCode != 200)
          throw Exception('Backend error: ${resp.statusCode}');
        final respJson = jsonDecode(resp.body);
        final checkoutUrl = respJson['url'] as String?;
        if (checkoutUrl == null || checkoutUrl.isEmpty)
          throw Exception('Checkout URL missing in backend response');
        html.window.open(checkoutUrl, '_self');
        return;
      }

      await stripe.Stripe.instance.presentPaymentSheet();
      if (context.mounted) {
        await showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('支払い完了'),
            content: const Text('お支払いが正常に完了しました。'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        await showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('エラー'),
            content: Text('お支払い処理中にエラーが発生しました:\n$e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } finally {
      setState(() => _processingPayment = false);
    }

    _orderCounter++;
    final orderId = _orderCounter.toString().padLeft(4, '0');
    final receiptOrders = List.from(orderHistory);
    setState(() => orderHistory.clear());

    final prefs = await SharedPreferences.getInstance();
    final List<String> purchaseHistoryList =
        prefs.getStringList('purchaseHistory') ?? [];

    final Map<String, dynamic> newOrder = {
      'orderId': orderId,
      'items': receiptOrders
          .map(
            (o) => {
              'label': o.item.labelKey,
              'price': o.item.price,
              'quantity': o.quantity,
              'subtotal': o.item.price * o.quantity,
            },
          )
          .toList(),
      'total': getTotal(),
      'email': effectiveEmail,
      'card': {},
      'address': effectiveAddress,
      'recipient': _recipientController.text.trim(),
      'giftMessage': isGift ? (_customMessageController.text) : '',
      'dateTime': DateTime.now().toIso8601String(),
    };

    purchaseHistoryList.add(jsonEncode(newOrder));
    await prefs.setStringList('purchaseHistory', purchaseHistoryList);

    setState(() {
      _emailController.clear();
      _addressController.clear();
      _customMessageController.clear();
      _recipientController.clear();
      isGift = false;
      selectedMessage = null;
      selectedSeason = '春';
    });
  }

  void _onBottomNavTap(int index) {
    if (_selectedBottomIndex == index) return;
    setState(() => _selectedBottomIndex = index);

    Widget targetScreen;
    switch (index) {
      case 0:
        targetScreen = const HomeScreen();
        break;
      case 1:
        targetScreen = const OrdersScreen();
        break;
      case 2:
        targetScreen = const OrderHistoryScreen();
        break;
      case 3:
        targetScreen = const MyPageScreen();
        break;
      default:
        return;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => targetScreen),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = getTotal();
    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: scaffoldBg,
        centerTitle: true,
        title: const Text('会計', style: TextStyle(color: Color(0xFF1A4D2E))),
        iconTheme: const IconThemeData(color: Color(0xFF1A4D2E)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // -----------------------------
            // 1️⃣ BOTÃO LOGIN TOPO
            // -----------------------------
            if (!isLoggedIn) ...[
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    // Chama MyPageScreen e aguarda retorno
                    final result = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(builder: (_) => const MyPageScreen()),
                    );

                    // Se o login foi bem-sucedido, atualiza o estado
                    if (result == true) {
                      await _loadLoginState();
                      setState(() {});
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: green,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(120, 40),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  child: const Text(
                    'ログイン',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              const Center(
                child: Text(
                  '登録するとメールと住所を保存できます',
                  style: TextStyle(color: green, fontSize: 12),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // -----------------------------
            // 2️⃣ Order list
            // -----------------------------
            Card(
              color: scaffoldBg,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '購入内容',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: green,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (orderHistory.isEmpty)
                      const Text(
                        '現在、レジに商品がありません',
                        style: TextStyle(color: green),
                      )
                    else
                      Column(
                        children: [
                          ...orderHistory.map((o) {
                            final subtotal = o.item.price * o.quantity;
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      o.item.labelKey,
                                      style: const TextStyle(color: green),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    '¥${o.item.price.toStringAsFixed(0)} × ${o.quantity}',
                                    style: const TextStyle(color: green),
                                  ),
                                  Text(
                                    ' = ¥${subtotal.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      color: green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          const Divider(thickness: 1),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                '合計金額',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: green,
                                ),
                              ),
                              Text(
                                '¥${getTotal().toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: green,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 8),

            // -----------------------------
            // 3️⃣ E-MAIL
            // -----------------------------
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'メールアドレス',
                  style: TextStyle(fontWeight: FontWeight.bold, color: green),
                ),
                const SizedBox(height: 4),
                Card(
                  color: scaffoldBg,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: TextField(
                      controller: _emailController,
                      maxLines: 1,
                      decoration: const InputDecoration(
                        hintText: 'メールアドレスを入力',
                        hintStyle: TextStyle(color: green),
                        labelStyle: TextStyle(color: green),
                        floatingLabelStyle: TextStyle(color: green),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: green),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: green, width: 2),
                        ),
                      ),
                      cursorColor: green,
                      style: const TextStyle(color: green),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // -----------------------------
            // 4️⃣ ENDEREÇO DE ENTREGA
            // -----------------------------
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '配送先住所',
                  style: TextStyle(fontWeight: FontWeight.bold, color: green),
                ),
                const SizedBox(height: 4),
                Card(
                  color: scaffoldBg,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: TextField(
                      controller: _addressController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        hintText: '住所を入力',
                        hintStyle: TextStyle(color: green),
                        labelStyle: TextStyle(color: green),
                        floatingLabelStyle: TextStyle(color: green),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: green),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: green, width: 2),
                        ),
                      ),
                      cursorColor: green,
                      style: const TextStyle(color: green),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // 5️⃣ Gift
            // -----------------------------
            CheckboxListTile(
              title: const Text('これはギフトです', style: TextStyle(color: green)),
              activeColor: green,
              value: isGift,
              onChanged: (v) => setState(() => isGift = v ?? false),
            ),
            if (isGift)
              Card(
                color: scaffoldBg,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '宛先名（受取人のお名前）',
                        style: TextStyle(color: green),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _recipientController,
                        decoration: const InputDecoration(
                          hintText: '受取人の名前を入力',
                          hintStyle: TextStyle(color: green),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: green),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: green, width: 2),
                          ),
                        ),
                        cursorColor: green,
                        style: const TextStyle(color: green),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        '日頃お世話になっている方へのメッセージをいくつかご提案します。\n'
                        '相手との関係性や状況に合わせてアレンジしてくださいね。\n',
                        style: TextStyle(color: green),
                      ),
                      const SizedBox(height: 12),

                      // Mensagens (自由に入力 primeiro)
                      ...List.generate(5, (index) {
                        final labels = [
                          '宛先の方に自由にメッセージをご記入ください。',
                          'フォーマル　「いつも大変お世話になっております。日頃の感謝の気持ちを込めて、心ばかりの品をお贈りさせていただきます。これからもどうぞよろしくお願いいたします。」',
                          'やや親しい関係　「いつもお世話になっております。日頃の感謝を込めて、ささやかですが贈らせていただきます。お口に合えば嬉しいです。」',
                          'もう少しカジュアル　「いつもありがとうございます。感謝の気持ちです。喜んでいただけたら嬉しいです。」',
                          '季節の挨拶を入れる　「${selectedSeason ?? '〇'}の候、いつもお世話になっております。日頃の感謝を込めて、心ばかりの品をお届けいたします。」',
                        ];

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RadioListTile<int>(
                              title: Text(
                                labels[index],
                                style: const TextStyle(color: green),
                              ),
                              value: index + 1,
                              groupValue: selectedMessage,
                              activeColor: green,
                              onChanged: (v) =>
                                  setState(() => selectedMessage = v),
                            ),

                            // 自由に入力
                            if (selectedMessage == index + 1 && index == 0)
                              Padding(
                                padding: const EdgeInsets.only(left: 32),
                                child: SizedBox(
                                  height: 100,
                                  child: TextField(
                                    controller: _customMessageController,
                                    maxLength: 80,
                                    maxLines: null,
                                    expands: true,
                                    textAlignVertical: TextAlignVertical.top,
                                    decoration: const InputDecoration(
                                      filled: true,
                                      fillColor: Color(0xFFF5F5F5),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(12),
                                        ),
                                        borderSide: BorderSide(color: green),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(12),
                                        ),
                                        borderSide: BorderSide(
                                          color: green,
                                          width: 2,
                                        ),
                                      ),
                                      contentPadding: EdgeInsets.all(12),
                                      counterText: '',
                                    ),
                                    cursorColor: green,
                                    style: const TextStyle(color: green),
                                  ),
                                ),
                              ),

                            // 季節の挨拶を入れる
                            if (selectedMessage == index + 1 && index == 4)
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 32,
                                  right: 8,
                                  top: 4,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      '季節を選択してください：',
                                      style: TextStyle(color: green),
                                    ),
                                    const SizedBox(height: 4),
                                    DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: selectedSeason,
                                        dropdownColor: scaffoldBg,
                                        style: const TextStyle(color: green),
                                        isDense: true,
                                        items: const [
                                          DropdownMenuItem(
                                            value: '春',
                                            child: Text('春'),
                                          ),
                                          DropdownMenuItem(
                                            value: '夏',
                                            child: Text('夏'),
                                          ),
                                          DropdownMenuItem(
                                            value: '秋',
                                            child: Text('秋'),
                                          ),
                                          DropdownMenuItem(
                                            value: '冬',
                                            child: Text('冬'),
                                          ),
                                        ],
                                        onChanged: (val) => setState(
                                          () => selectedSeason = val,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 8),
            Text(
              '合計: ¥${total.toStringAsFixed(0)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: green,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: canCheckout() ? _checkoutAll : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: canCheckout() ? green : Colors.grey,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 45),
                ),
                child: _processingPayment
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Text(
                        '注文を確定する',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedBottomIndex,
        onTap: _onBottomNavTap,
      ),
    );
  }
}
