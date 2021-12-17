import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sergipe_shop/finalizar_pedido/text_fiel.dart';
import 'package:sergipe_shop/home_page/widgets/item_card.dart';

import 'package:sergipe_shop/models/produto_model.dart';
import 'package:sergipe_shop/utils/snack_bar.dart';

class FinalizarPage extends StatefulWidget {
  final ValueNotifier<List<Produto>> produtos;
  const FinalizarPage({
    Key? key,
    required this.produtos,
  }) : super(key: key);

  @override
  _FinalizarPageState createState() => _FinalizarPageState();
}

var clientesCollection = FirebaseFirestore.instance.collection('clientes');
User currentUser = FirebaseAuth.instance.currentUser!;
TextEditingController controllerEmail =
    TextEditingController(text: currentUser.email);
TextEditingController controllerNome =
    TextEditingController(text: currentUser.displayName);
TextEditingController controllerLogradouro = TextEditingController();
TextEditingController controllerFormarDePagamento = TextEditingController();

class _FinalizarPageState extends State<FinalizarPage> {
  relizarPedido() async {
    try {
      await FirebaseFirestore.instance.collection('pedidos').add({
        'cliente': {
          'nome': controllerNome.text,
          'email': controllerEmail.text,
          'userId': currentUser.uid,
        },
        'produtos': widget.produtos.value.map((e) => e.toMap()).toList(),
        'endereco': controllerLogradouro.text,
        'forma_de_pagamento': controllerFormarDePagamento.text,
        'status': true
      });
      clientesCollection.doc(currentUser.uid).set({
        'nome': controllerNome.text,
        'userId': currentUser.uid,
        'endereco': controllerLogradouro.text,
      });
      return true;
    } catch (e) {
      debugPrint('error $e');
      return false;
    }
  }

  Future<void> confirmarPedidoDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView(
              shrinkWrap: true,
              children: [
                Text('Dados Para Entrega',
                    style: Theme.of(context).textTheme.headline5),
                const SizedBox(
                  height: 10,
                ),
                TextFieldOutlineBorder(
                  controller: controllerNome,
                  labelText: 'Nome',
                  textInputFormatter:
                      FilteringTextInputFormatter.singleLineFormatter,
                ),
                const SizedBox(
                  height: 30,
                ),
                TextFieldOutlineBorder(
                  controller: controllerEmail,
                  labelText: 'Email',
                  textInputFormatter:
                      FilteringTextInputFormatter.singleLineFormatter,
                ),
                const SizedBox(
                  height: 30,
                ),
                TextFieldOutlineBorder(
                  controller: controllerLogradouro,
                  labelText: 'Logradouro',
                  textInputFormatter:
                      FilteringTextInputFormatter.singleLineFormatter,
                ),
                const SizedBox(
                  height: 30,
                ),
                TextFieldOutlineBorder(
                  controller: controllerFormarDePagamento,
                  labelText: 'Forma de Pagamento',
                  textInputFormatter:
                      FilteringTextInputFormatter.singleLineFormatter,
                ),
                const SizedBox(
                  height: 30,
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (await relizarPedido()) {
                      Navigator.pop(context);
                      SnackBarMessage.sucess(context, 'Pedido Realizado');
                    } else {
                      Navigator.pop(context);
                      SnackBarMessage.sucess(
                          context, 'Erro ao finalizar pedido');
                      debugPrint('Error');
                    }
                  },
                  child: const Text(
                    'Realizar Pedido',
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Finalizar Pedido'),
      ),
      body: ListView(
        children: widget.produtos.value.map((Produto item) {
          return ItemCard(
            produto: item,
            carrinhoDeCompras: widget.produtos,
            finalizarPedido: true,
            // pedidoPage: true,
          );
          // SizedBox(
          //   child: Card(
          //     semanticContainer: true,
          //     clipBehavior: Clip.antiAliasWithSaveLayer,
          //     child: Stack(
          //       alignment: Alignment.bottomRight,
          //       children: [
          //         Row(
          //           crossAxisAlignment: CrossAxisAlignment.start,
          //           children: [
          //             SizedBox(
          //               height: 100,
          //               width: 100,
          //               child: Image.network(
          //                 item.imagem,
          //                 loadingBuilder: (context, child, loadingProgress) {
          //                   return loadingProgress != null
          //                       ? const SizedBox(
          //                           height: 100,
          //                           width: 100,
          //                           child: Center(
          //                               child: CircularProgressIndicator()),
          //                         )
          //                       : child;
          //                 },
          //                 fit: BoxFit.fill,
          //               ),
          //             ),
          //             Column(
          //               crossAxisAlignment: CrossAxisAlignment.start,
          //               children: const [
          //                 Padding(
          //                   padding: EdgeInsets.only(top: 10, left: 10),
          //                   child: Text('Item Name'),
          //                 ),
          //                 Padding(
          //                   padding: EdgeInsets.only(top: 2, left: 10),
          //                   child: Text('Descrição do produto'),
          //                 ),
          //               ],
          //             ),
          //           ],
          //         ),
          //       ],
          //     ),
          //     shape: RoundedRectangleBorder(
          //       borderRadius: BorderRadius.circular(10.0),
          //     ),
          //     elevation: 5,
          //     margin: const EdgeInsets.all(10),
          //   ),
          // );
        }).toList(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 30),
        child: SizedBox(
          width: 150,
          height: 50,
          child: ElevatedButton(
              style: const ButtonStyle(),
              onPressed: () {
                confirmarPedidoDialog(context);
              },
              child: const Text('Fazer Pedido')),
        ),
      ),
    );
  }
}
