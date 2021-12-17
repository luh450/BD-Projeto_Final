// ignore_for_file: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member

import 'package:flutter/material.dart';

import 'package:sergipe_shop/models/produto_model.dart';
import 'package:sergipe_shop/utils/extensions.dart';

// ignore: must_be_immutable
class ItemCard extends StatefulWidget {
  Produto produto;
  ValueNotifier<List<Produto>> carrinhoDeCompras;
  bool adminPage;
  bool pedidoPage;
  bool finalizarPedido;
  dynamic pedidoDetails;
  ItemCard({
    Key? key,
    // ignore: prefer_collection_literals
    required this.produto,
    required this.carrinhoDeCompras,
    this.adminPage = false,
    this.pedidoPage = false,
    this.finalizarPedido = false,
    this.pedidoDetails = dynamic,
  }) : super(key: key);

  @override
  _ItemCardState createState() => _ItemCardState();
}

class _ItemCardState extends State<ItemCard> {
  adicionarAoCarrinho(Produto produto) {
    widget.carrinhoDeCompras.value.add(produto);
  }

  removerDoCarrinho(Produto produto) {
    widget.carrinhoDeCompras.value.remove(produto);
  }

  int quantidadeSelecionada = 0;
  bool adicionado = false;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Card(
        semanticContainer: true,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: Stack(
          alignment: Alignment.centerRight,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 100,
                  width: 100,
                  child: Image.network(
                    widget.produto.imagem,
                    loadingBuilder: (context, child, loadingProgress) {
                      return loadingProgress != null
                          ? const SizedBox(
                              height: 100,
                              width: 100,
                              child: Center(child: CircularProgressIndicator()),
                            )
                          : child;
                    },
                    fit: BoxFit.fill,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 10, left: 10),
                      child: Text(widget.produto.nome),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 2, left: 10),
                      child: Text(widget.produto.descricao),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10, left: 10),
                      child: Text(
                        widget.produto.valor.currencyFormat(),
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            !widget.adminPage && !widget.finalizarPedido
                ? Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: !adicionado
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton(
                                  onPressed: () {
                                    adicionado = true;
                                    quantidadeSelecionada = 1;
                                    adicionarAoCarrinho(widget.produto);
                                    widget.carrinhoDeCompras.notifyListeners();
                                    setState(() {});
                                  },
                                  child: const Icon(
                                      Icons.add_shopping_cart_outlined))
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  quantidadeSelecionada--;
                                  removerDoCarrinho(widget.produto);
                                  if (quantidadeSelecionada == 0) {
                                    adicionado = false;
                                  }
                                  widget.carrinhoDeCompras.notifyListeners();

                                  setState(() {});
                                },
                                child: const Icon(
                                  Icons.remove,
                                  color: Colors.white,
                                  size: 30.0,
                                ),
                                style: ElevatedButton.styleFrom(
                                    shape: const CircleBorder(),
                                    primary: Colors.green),
                              ),
                              Text(
                                ' $quantidadeSelecionada ',
                                style: const TextStyle(fontSize: 18),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  quantidadeSelecionada++;
                                  adicionarAoCarrinho(widget.produto);
                                  widget.carrinhoDeCompras.notifyListeners();
                                  setState(() {});
                                },
                                child: const Icon(
                                  Icons.add,
                                  size: 30.0,
                                ),
                                style: ElevatedButton.styleFrom(
                                    shape: const CircleBorder(),
                                    primary: Colors.green),
                              ),
                            ],
                          ))
                : widget.pedidoPage
                    ? Container(
                        alignment: Alignment.bottomRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: Column(
                          children: [
                            Text(
                              '''${widget.pedidoDetails['cliente']['nome']}''',
                            ),
                          ],
                        ),
                      )
                    : Container(),
          ],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        elevation: 5,
        margin: const EdgeInsets.all(10),
      ),
    );
  }
}
