import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/order_history.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import 'home_screen.dart';
import 'orders_screen.dart';
import 'mypage_screen.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  int _selectedBottomIndex = 2;
  static int _orderCounter = 0;

  // blocos info
  List<String> emails = [];
  List<Map<String, String>> creditCards = [];
  List<String> addresses = [];

  int? selectedEmail;
  int? selectedCard;
  int? selectedAddress;

  bool newEmailSelected = false;
  bool newCardSelected = false;
  bool newAddressSelected = false;

  String tempEmail = '';
  Map<String, String> tempCard = {};
  String tempAddress = '';

  bool saveEmail = false;
  bool saveCard = false;
  bool saveAddress = false;

  // ギフト関連
  bool isGift = false;
  int? selectedMessage;
  String? selectedSeason = '春';
  final TextEditingController _customMessageController =
      TextEditingController();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _cardNameController = TextEditingController();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _cardExpiryController = TextEditingController();
  final TextEditingController _cardPhoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  static const Color green = Color(0xFF307A59);
  static const Color scaffoldBg = Color(0xFFE5E9EC);

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      emails = prefs.getStringList('emails') ?? [];
      addresses = prefs.getStringList('addresses') ?? [];
      final cardList = prefs.getStringList('creditCards') ?? [];
      creditCards = cardList
          .map((e) => Map<String, String>.from(jsonDecode(e)))
          .toList();
    });
  }

  Future<void> _savePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('emails', emails);
    await prefs.setStringList('addresses', addresses);
    await prefs.setStringList(
      'creditCards',
      creditCards.map((c) => jsonEncode(c)).toList(),
    );
  }

  double getTotal() {
    return orderHistory.fold(
      0,
      (sum, item) => sum + item.item.price * item.quantity,
    );
  }

  Future<void> _checkoutAll() async {
    if (orderHistory.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        double totalGeral = getTotal();

        // Seleciona os dados de email, cartão e endereço
        String email = newEmailSelected
            ? tempEmail
            : (selectedEmail != null ? emails[selectedEmail!] : '');
        Map<String, String> card = newCardSelected
            ? tempCard
            : (selectedCard != null ? creditCards[selectedCard!] : {});
        String address = newAddressSelected
            ? tempAddress
            : (selectedAddress != null ? addresses[selectedAddress!] : '');

        // Mensagem de presente
        String? giftMsg;
        if (isGift) {
          switch (selectedMessage) {
            case 1:
              giftMsg =
                  '「いつも大変お世話になっております。日頃の感謝の気持ちを込めて、心ばかりの品をお贈りさせていただきます。これからもどうぞよろしくお願いいたします。」';
              break;
            case 2:
              giftMsg =
                  '「いつもお世話になっております。日頃の感謝を込めて、ささやかですが贈らせていただきます。お口に合えば嬉しいです。」';
              break;
            case 3:
              giftMsg = '「いつもありがとうございます。感謝の気持ちです。喜んでいただけたら嬉しいです。」';
              break;
            case 4:
              giftMsg =
                  '「${selectedSeason ?? '〇'}の候、いつもお世話になっております。日頃の感謝を込めて、心ばかりの品をお届けいたします。」';
              break;
            case 5:
              giftMsg = _customMessageController.text;
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

                  // Produtos
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '商品',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: green,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
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
                  // Informações de contato e entrega
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'メールアドレス: $email',
                          style: const TextStyle(color: green),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'カード名義人: ${card['name'] ?? ''}',
                              style: const TextStyle(color: green),
                            ),
                            Text(
                              'カード番号: **** **** **** ${card['number'] != null && card['number']!.length >= 4 ? card['number']!.substring(card['number']!.length - 4) : ''}',
                              style: const TextStyle(color: green),
                            ),
                            if (card['expiry'] != null &&
                                card['expiry']!.isNotEmpty)
                              Text(
                                '有効期限: ${card['expiry']}', // aqui você deve garantir que expiry esteja no formato MM/YYYY
                                style: const TextStyle(color: green),
                              ),
                            if (card['phone'] != null &&
                                card['phone']!.isNotEmpty)
                              Text(
                                '電話番号: ${card['phone']}',
                                style: const TextStyle(color: green),
                              ),
                          ],
                        ),

                        Text(
                          '配送先住所: $address',
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
                  // Botões
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

    // gera ID incremental
    _orderCounter++;
    final orderId = _orderCounter.toString().padLeft(4, '0');

    final receiptOrders = List.from(orderHistory);

    // limpa histórico
    setState(() => orderHistory.clear());

    // Salva info nova apenas se radio selecionado e checkbox marcado
    if (newEmailSelected && saveEmail && tempEmail.isNotEmpty) {
      emails.add(tempEmail);
    }
    if (newCardSelected && saveCard && tempCard.isNotEmpty) {
      creditCards.add(tempCard);
    }
    if (newAddressSelected && saveAddress && tempAddress.isNotEmpty) {
      addresses.add(tempAddress);
    }
    _savePrefs();

    // Determina mensagem de ギフト (se houver)
    String? giftMessage;
    if (isGift) {
      switch (selectedMessage) {
        case 1:
          giftMessage =
              '「いつも大変お世話になっております。日頃の感謝の気持ちを込めて、心ばかりの品をお贈りさせていただきます。これからもどうぞよろしくお願いいたします。」';
          break;
        case 2:
          giftMessage =
              '「いつもお世話になっております。日頃の感謝を込めて、ささやかですが贈らせていただきます。お口に合えば嬉しいです。」';
          break;
        case 3:
          giftMessage = '「いつもありがとうございます。感謝の気持ちです。喜んでいただけたら嬉しいです。」';
          break;
        case 4:
          giftMessage =
              '「${selectedSeason ?? '〇'}の候、いつもお世話になっております。日頃の感謝を込めて、心ばかりの品をお届けいたします。」';
          break;
        case 5:
          giftMessage = _customMessageController.text;
          break;
        default:
          giftMessage = null;
      }
    }

    // ---- JANELA COM OS PEDIDOS DO CARRINHO ----
    await showDialog(
      context: context,
      builder: (ctx) {
        double totalGeral = 0;
        const String orderInfoMsg =
            'ご案内：注文内容の確認やキャンセルをご希望の場合は、マイページの購入履歴タブをご覧ください。';
        return Dialog(
          backgroundColor: scaffoldBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    'ご利用ありがとうございました。',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: green,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 6),
                Center(
                  child: Text(
                    '注文番号: $orderId',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Courier',
                      color: green,
                    ),
                  ),
                ),
                const Divider(thickness: 2),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 300),
                  child: ListView(
                    shrinkWrap: true,
                    children: receiptOrders.map((o) {
                      double subtotal = o.item.price * o.quantity;
                      totalGeral += subtotal;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              o.item.labelKey,
                              style: const TextStyle(
                                fontSize: 16,
                                color: green,
                              ),
                            ),
                            Text(
                              '¥${o.item.price.toStringAsFixed(0)} × ${o.quantity}',
                              style: const TextStyle(color: green),
                            ),
                            const Divider(),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '合計',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: green,
                      ),
                    ),
                    Text(
                      '¥${totalGeral.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ---- Mensagem de instrução ----
                Text(orderInfoMsg, style: const TextStyle(color: green)),

                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('購入ありがとうございました！またのご利用をお待ちしております。'),
                          duration: Duration(seconds: 3),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: green,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 45),
                    ),
                    child: const Text('閉じる'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    // SALVA NO PURCHASE HISTORY
    final prefs = await SharedPreferences.getInstance();
    final List<String> purchaseHistoryList =
        prefs.getStringList('purchaseHistory') ?? [];

    // Cria Map do pedido atual
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
      'email': newEmailSelected
          ? tempEmail
          : (selectedEmail != null ? emails[selectedEmail!] : ''),
      'card': newCardSelected
          ? tempCard
          : (selectedCard != null ? creditCards[selectedCard!] : {}),
      'address': newAddressSelected
          ? tempAddress
          : (selectedAddress != null ? addresses[selectedAddress!] : ''),
      'giftMessage': giftMessage ?? '',
      'dateTime': DateTime.now().toIso8601String(),
    };

    // Adiciona à lista e salva
    purchaseHistoryList.add(jsonEncode(newOrder));
    await prefs.setStringList('purchaseHistory', purchaseHistoryList);

    // Reset temporários e radios novas infos
    setState(() {
      tempEmail = '';
      tempCard = {};
      tempAddress = '';
      newEmailSelected = false;
      newCardSelected = false;
      newAddressSelected = false;
      selectedEmail = null;
      selectedCard = null;
      selectedAddress = null;
      saveEmail = false;
      saveCard = false;
      saveAddress = false;
      _emailController.clear();
      _cardNameController.clear();
      _cardNumberController.clear();
      _cardExpiryController.clear();
      _cardPhoneController.clear();
      _addressController.clear();

      isGift = false;
      selectedMessage = null;
      selectedSeason = '春';
      _customMessageController.clear();
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

  Widget _buildInfoBlock({
    required String title,
    required List items,
    required String type,
  }) {
    bool newSelected = type == "email"
        ? newEmailSelected
        : type == "card"
        ? newCardSelected
        : newAddressSelected;
    return Card(
      color: scaffoldBg,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, color: green),
            ),
            const SizedBox(height: 4),
            if (items.isEmpty)
              const Text('登録されていません', style: TextStyle(color: green)),
            ...items.asMap().entries.map((entry) {
              int idx = entry.key;
              var val = entry.value;
              return RadioListTile<int>(
                value: idx,
                groupValue: type == "card"
                    ? (newCardSelected ? null : selectedCard)
                    : type == "email"
                    ? (newEmailSelected ? null : selectedEmail)
                    : (newAddressSelected ? null : selectedAddress),
                title: type == "card"
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '名義人: ${val['name']}',
                            style: const TextStyle(color: green),
                          ),
                          Text(
                            '**** **** **** ${val['number']!.substring(val['number']!.length - 4)}',
                            style: const TextStyle(color: green),
                          ),
                          if (val['expiry'] != null &&
                              val['expiry']!.isNotEmpty)
                            Text(
                              '有効期限: ${val['expiry']}',
                              style: const TextStyle(color: green),
                            ),
                          if (val['phone'] != null && val['phone']!.isNotEmpty)
                            Text(
                              '電話番号: ${val['phone']}',
                              style: const TextStyle(color: green),
                            ),
                        ],
                      )
                    : Text(
                        val.toString(),
                        style: const TextStyle(color: green),
                      ),
                activeColor: green,
                onChanged: (v) {
                  setState(() {
                    if (type == "email") {
                      selectedEmail = v;
                      newEmailSelected = false;
                    }
                    if (type == "card") {
                      selectedCard = v;
                      newCardSelected = false;
                    }
                    if (type == "address") {
                      selectedAddress = v;
                      newAddressSelected = false;
                    }
                  });
                },
              );
            }).toList(),

            Row(
              children: [
                Radio<bool>(
                  value: true,
                  groupValue: newSelected,
                  activeColor: green,
                  onChanged: (v) {
                    setState(() {
                      if (type == "email") {
                        newEmailSelected = true;
                        selectedEmail = null;
                        tempEmail = '';
                      }
                      if (type == "card") {
                        newCardSelected = true;
                        selectedCard = null;
                        tempCard = {};
                      }
                      if (type == "address") {
                        newAddressSelected = true;
                        selectedAddress = null;
                        tempAddress = '';
                      }
                    });
                  },
                ),
                const Text('新しく入力', style: TextStyle(color: green)),
              ],
            ),
            if (newSelected)
              Column(
                children: [
                  if (type == "email")
                    TextField(
                      controller: _emailController,
                      maxLines: 1,
                      onChanged: (v) => tempEmail = v,
                      decoration: InputDecoration(
                        labelText: 'メールアドレスを入力',
                        labelStyle: const TextStyle(color: green),
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
                  if (type == "card")
                    Column(
                      children: [
                        TextField(
                          controller: _cardNameController,
                          maxLines: 1,
                          onChanged: (v) => tempCard['name'] = v,
                          decoration: InputDecoration(
                            labelText: 'カード名義人',
                            labelStyle: const TextStyle(color: green),
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
                        const SizedBox(height: 4),
                        TextField(
                          controller: _cardNumberController,
                          maxLines: 1,
                          onChanged: (v) => tempCard['number'] = v,
                          decoration: InputDecoration(
                            labelText: 'カード番号',
                            labelStyle: const TextStyle(color: green),
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
                        const SizedBox(height: 4),
                        TextField(
                          controller: _cardExpiryController,
                          maxLines: 1,
                          onChanged: (v) => tempCard['expiry'] = v,
                          decoration: InputDecoration(
                            labelText: '有効期限',
                            labelStyle: const TextStyle(color: green),
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
                        const SizedBox(height: 4),
                        TextField(
                          controller: _cardPhoneController,
                          maxLines: 1,
                          onChanged: (v) => tempCard['phone'] = v,
                          decoration: InputDecoration(
                            labelText: '電話番号',
                            labelStyle: const TextStyle(color: green),
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
                      ],
                    ),
                  if (type == "address")
                    TextField(
                      controller: _addressController,
                      maxLines: 2,
                      onChanged: (v) => tempAddress = v,
                      decoration: InputDecoration(
                        labelText: '配送先住所',
                        labelStyle: const TextStyle(color: green),
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
                  Row(
                    children: [
                      Checkbox(
                        value: type == "email"
                            ? saveEmail
                            : type == "card"
                            ? saveCard
                            : saveAddress,
                        onChanged: (v) {
                          setState(() {
                            if (type == "email") saveEmail = v!;
                            if (type == "card") saveCard = v!;
                            if (type == "address") saveAddress = v!;
                          });
                        },
                        activeColor: green,
                      ),
                      const Text('この情報を保存する', style: TextStyle(color: green)),
                    ],
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  bool canCheckout() {
    if (orderHistory.isEmpty) return false;

    bool emailOk =
        (selectedEmail != null) || (newEmailSelected && tempEmail.isNotEmpty);
    bool cardOk =
        (selectedCard != null) ||
        (newCardSelected &&
            tempCard.isNotEmpty &&
            tempCard.values.every((v) => v.isNotEmpty));
    bool addressOk =
        (selectedAddress != null) ||
        (newAddressSelected && tempAddress.isNotEmpty);

    return emailOk && cardOk && addressOk;
  }

  @override
  Widget build(BuildContext context) {
    final total = getTotal();
    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: scaffoldBg,
        centerTitle: true,
        title: const Text(
          'チェックアウト',
          style: TextStyle(color: Color(0xFF1A4D2E)),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF1A4D2E)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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

            _buildInfoBlock(title: 'メールアドレス', items: emails, type: "email"),
            const SizedBox(height: 8),
            _buildInfoBlock(
              title: 'クレジットカード情報',
              items: creditCards,
              type: "card",
            ),
            const SizedBox(height: 8),
            _buildInfoBlock(title: '配送先住所', items: addresses, type: "address"),
            const SizedBox(height: 8),

            // ---- ギフトセクション ----
            CheckboxListTile(
              title: const Text('これはギフトです', style: TextStyle(color: green)),
              activeColor: green,
              value: isGift,
              onChanged: (v) => setState(() => isGift = v!),
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
                        '日頃お世話になっている方へのメッセージをいくつかご提案します。'
                        '相手との関係性や状況に合わせてアレンジしてくださいね。\n'
                        'オプションを選択すると、対応するメッセージ例が表示されます',
                        style: TextStyle(color: green),
                      ),
                      const SizedBox(height: 12),

                      // Opção 1: フォーマル
                      RadioListTile<int>(
                        title: const Text(
                          'フォーマル',
                          style: TextStyle(color: green),
                        ),
                        value: 1,
                        groupValue: selectedMessage,
                        activeColor: green,
                        onChanged: (v) => setState(() => selectedMessage = v),
                      ),
                      if (selectedMessage == 1)
                        const Padding(
                          padding: EdgeInsets.only(left: 32),
                          child: Text(
                            '「いつも大変お世話になっております。日頃の感謝の気持ちを込めて、'
                            '心ばかりの品をお贈りさせていただきます。これからもどうぞよろしくお願いいたします。」',
                            style: TextStyle(color: green),
                          ),
                        ),

                      // Opção 2: やや親しい関係
                      RadioListTile<int>(
                        title: const Text(
                          'やや親しい関係',
                          style: TextStyle(color: green),
                        ),
                        value: 2,
                        groupValue: selectedMessage,
                        activeColor: green,
                        onChanged: (v) => setState(() => selectedMessage = v),
                      ),
                      if (selectedMessage == 2)
                        const Padding(
                          padding: EdgeInsets.only(left: 32),
                          child: Text(
                            '「いつもお世話になっております。日頃の感謝を込めて、'
                            'ささやかですが贈らせていただきます。お口に合えば嬉しいです。」',
                            style: TextStyle(color: green),
                          ),
                        ),

                      // Opção 3: もう少しカジュアル
                      RadioListTile<int>(
                        title: const Text(
                          'もう少しカジュアル',
                          style: TextStyle(color: green),
                        ),
                        value: 3,
                        groupValue: selectedMessage,
                        activeColor: green,
                        onChanged: (v) => setState(() => selectedMessage = v),
                      ),
                      if (selectedMessage == 3)
                        const Padding(
                          padding: EdgeInsets.only(left: 32),
                          child: Text(
                            '「いつもありがとうございます。感謝の気持ちです。喜んでいただけたら嬉しいです。」',
                            style: TextStyle(color: green),
                          ),
                        ),

                      // Opção 4: 季節の挨拶を入れる
                      RadioListTile<int>(
                        title: const Text(
                          '季節の挨拶を入れる',
                          style: TextStyle(color: green),
                        ),
                        value: 4,
                        groupValue: selectedMessage,
                        activeColor: green,
                        onChanged: (v) => setState(() => selectedMessage = v),
                      ),
                      // ---- Opção 4: Mensagem de acordo com a estação ----
                      if (selectedMessage == 4)
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 32,
                            right: 8,
                            top: 4,
                          ),
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                color: green,
                                fontSize: 14,
                              ),
                              children: [
                                const TextSpan(text: '「'),
                                WidgetSpan(
                                  alignment: PlaceholderAlignment.middle,
                                  child: SizedBox(
                                    width: 70, // largura do dropdown
                                    child: DropdownButtonHideUnderline(
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
                                  ),
                                ),
                                const TextSpan(
                                  text:
                                      'の候、いつもお世話になっております。日頃の感謝を込めて、心ばかりの品をお届けいたします。」',
                                ),
                              ],
                            ),
                          ),
                        ),

                      // Opção 5: 自由入力
                      RadioListTile<int>(
                        title: const Text(
                          '相手の方との関係性、贈り物の内容、季節などを教えていただければ、より具体的なメッセージをご提案できますよ。',
                          style: TextStyle(color: green),
                        ),
                        value: 5,
                        groupValue: selectedMessage,
                        activeColor: green,
                        onChanged: (v) => setState(() => selectedMessage = v),
                      ),
                      if (selectedMessage == 5)
                        Padding(
                          padding: const EdgeInsets.only(left: 32, right: 8),
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
                    ],
                  ),
                ),
              ),

            // ---- total + botão ----
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
                onPressed: canCheckout()
                    ? _checkoutAll
                    : null, // ← usa canCheckout()
                style: ElevatedButton.styleFrom(
                  backgroundColor: canCheckout()
                      ? green
                      : Colors.grey, // muda cor conforme estado
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 45),
                ),
                child: const Text(
                  '注文を確定する',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
