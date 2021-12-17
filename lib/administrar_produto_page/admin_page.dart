import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sergipe_shop/finalizar_pedido/text_fiel.dart';
import 'package:sergipe_shop/home_page/widgets/item_card.dart';
import 'package:sergipe_shop/models/produto_model.dart';
import 'package:sergipe_shop/utils/app_colors.dart';
import 'package:sergipe_shop/utils/extensions.dart';
import 'package:sergipe_shop/utils/snack_bar.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({Key? key}) : super(key: key);

  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  var produtos = FirebaseFirestore.instance.collection('produtos').snapshots();
  var pedidos = FirebaseFirestore.instance.collection('pedidos').snapshots();
  var produtosList = FirebaseFirestore.instance.collection('produtos');
  List<String> filtroSelecionado = [];
  List<String> categList = [];
  ValueNotifier<List<Produto>> carrinhoDeCompras = ValueNotifier([]);
  var categoriasSnap =
      FirebaseFirestore.instance.collection('categorias').snapshots();
  var categoriasList = FirebaseFirestore.instance.collection('categorias');
  filter(Map<String, dynamic> data, Color? color) {
    String filter = data['nome'];

    if (filtroSelecionado.contains(filter)) {
      filtroSelecionado.remove(filter);
    } else {
      filtroSelecionado.add(filter);
    }
  }

  final CurrencyTextInputFormatter formatter =
      CurrencyTextInputFormatter(name: 'br', symbol: 'R\$');

  removerCategoria(
      DocumentSnapshot<Object?> document, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Remover Categoria'),
          content: Text(
            data['nome'],
            style: Theme.of(context).textTheme.headline5,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                categoriasList.doc(document.id).delete().then((value) {
                  Navigator.pop(context);
                  // ignore: invalid_return_type_for_catch_error
                }).catchError((error) => debugPrint(error));
              },
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }

  TextEditingController controllerNomeDoProduto = TextEditingController();
  TextEditingController controllerCategoriaProduto = TextEditingController();
  TextEditingController controllerImagemUrl = TextEditingController();
  TextEditingController controllerValor = TextEditingController();
  TextEditingController controllerMarca = TextEditingController();
  TextEditingController controllerDescricao = TextEditingController();
  cleanFields() {
    controllerNomeDoProduto.clear();
    controllerCategoriaProduto.clear();
    controllerImagemUrl.clear();
    controllerValor.clear();
    controllerMarca.clear();
    controllerDescricao.clear();
  }

  checkCat() async {
    categList.clear();
    await categoriasList.get().then((QuerySnapshot value) {
      for (var element in value.docs) {
        categList.add(element['nome']);
      }
    });
    if (categList.contains(controllerCategoriaProduto.text.capitalize())) {
      return;
    } else {
      categoriasList.add({
        'nome': controllerCategoriaProduto.text.capitalize(),
      });
      categList.add(controllerCategoriaProduto.text.capitalize());
    }
  }

  addProduto() async {
    await checkCat();
    produtosList.add({
      'categoria': controllerCategoriaProduto.text.capitalize(),
      'imagem': controllerImagemUrl.text,
      'nome': controllerNomeDoProduto.text,
      'marca': controllerMarca.text,
      'descricao': controllerDescricao.text,
      'valor': formatter.getUnformattedValue(),
    }).then((value) {
      Navigator.pop(context);
      // Fluttertoast.showToast(msg: 'Produtos Salvo', co);
      SnackBarMessage.sucess(context, 'Produto Adicionado');
      cleanFields();
      // return true;
    }).catchError(
      (onError) {
        debugPrint("Failed to delete user's property: $onError");
        Navigator.pop(context);
        SnackBarMessage.error(context, 'Erro $onError');
      },
    );
  }

  editarProduto(Produto produto) {
    checkCat();
    produtosList.doc(produto.uid).update({
      'categoria': controllerCategoriaProduto.text.capitalize(),
      'imagem': controllerImagemUrl.text,
      'nome': controllerNomeDoProduto.text,
      'marca': controllerMarca.text,
      'descricao': controllerDescricao.text,
      'valor': formatter.getUnformattedValue(),
    }).then((value) {
      debugPrint('Salvo');
      Navigator.pop(context);
      SnackBarMessage.sucess(context, 'Produto Atualizado');
      cleanFields();
    }).catchError(
      (onError) {
        debugPrint("Failed to delete user's property: $onError");
        Navigator.pop(context);
        SnackBarMessage.error(context, 'Erro $onError');
      },
    );
  }

  sugest() async {
    List<String> tempListField = [];
    await categoriasList.get().then((QuerySnapshot value) {
      for (var element in value.docs) {
        tempListField.add(element['nome']);
      }
    });
    return tempListField;
  }

  addOrEditProdutoDialog({Produto? produto, bool edit = false}) async {
    if (produto != null) {
      controllerNomeDoProduto.text = produto.nome;
      controllerCategoriaProduto.text = produto.categoria;
      controllerImagemUrl.text = produto.imagem;

      controllerDescricao.text = produto.descricao;
      controllerMarca.text = produto.marca;
      controllerValor.text = produto.valor.toString();
    } else {
      controllerNomeDoProduto.text = '';
      controllerCategoriaProduto.text = '';
      controllerImagemUrl.text = '';
    }

    // await sugest();
    var dia = await showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView(
              shrinkWrap: true,
              // mainAxisAlignment: MainAxisAlignment.center,
              // mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Adicionar Produto',
                  style: Theme.of(context).textTheme.headline5,
                ),
                const SizedBox(
                  height: 30,
                ),
                TextFieldOutlineBorder(
                  labelText: 'Nome do Produto',
                  controller: controllerNomeDoProduto,
                  textInputFormatter:
                      FilteringTextInputFormatter.singleLineFormatter,
                ),
                TextFieldOutlineBorder(
                  labelText: 'Marca',
                  controller: controllerMarca,
                  textInputFormatter:
                      FilteringTextInputFormatter.singleLineFormatter,
                ),
                TextFieldOutlineBorder(
                  labelText: 'Descrição',
                  controller: controllerDescricao,
                  textInputFormatter:
                      FilteringTextInputFormatter.singleLineFormatter,
                ),
                TextFieldOutlineBorder(
                  labelText: 'Valor',
                  initialValue: produto != null
                      ? formatter.format(produto.valor.toString())
                      : '',
                  controller: controllerValor,
                  textInputType: TextInputType.number,
                  textInputFormatter: formatter,
                ),
                TextFieldOutlineBorder(
                  labelText: 'Categoria',
                  controller: controllerCategoriaProduto,
                  textInputFormatter:
                      FilteringTextInputFormatter.singleLineFormatter,
                ),
                // Autocomplete<String>(
                //   optionsBuilder: (textEditingValue) async {
                //     return await sugest();
                //   },
                //   onSelected: (v) {
                //     controllerCategoriaProduto.text = v;
                //   },
                //   fieldViewBuilder: (context, textEditingController, focusNode,
                //       onFieldSubmitted) {
                //     return TextField(
                //       onChanged: (v) {
                //         controllerCategoriaProduto.text = v;
                //       },
                //       onSubmitted: (value) {
                //         onFieldSubmitted();
                //         controllerCategoriaProduto.text = value;
                //       },
                //       focusNode: focusNode,
                //       controller: textEditingController,
                //       decoration: const InputDecoration(
                //           border: OutlineInputBorder(), labelText: 'Categoria'),
                //     );
                //   },
                // ),

                TextFieldOutlineBorder(
                  labelText: 'Url Imagem',
                  controller: controllerImagemUrl,
                  textInputFormatter:
                      FilteringTextInputFormatter.singleLineFormatter,
                ),
                ElevatedButton(
                  onPressed: () {
                    // print(formatter.getUnformattedValue());
                    if (edit) {
                      editarProduto(produto!);
                    } else {
                      addProduto();
                    }
                    // Navigator.pop(context);
                    // return true;
                  },
                  child: Text(edit ? 'Atualizar' : 'Adicionar'),
                ),
              ],
            ),
          ),
        );
      },
    );
    cleanFields();
    // return dia;
  }

  removerProduto(Produto produto) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Remover Produto'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                produtosList.doc(produto.uid).delete().then((value) {
                  debugPrint('Deletado');
                  Navigator.pop(context);
                }).catchError((error) =>
                    // ignore: invalid_return_type_for_catch_error
                    debugPrint("Failed to delete user's property: $error"));
              },
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Page'),
          bottom: const TabBar(
            tabs: [
              Tab(
                icon: Icon(Icons.settings),
              ),
              Tab(
                icon: Icon(Icons.list_alt_outlined),
              ),
            ],
          ),
        ),
        body: TabBarView(children: [
          Column(
            children: [
              SizedBox(
                height: 70,
                child: StreamBuilder<QuerySnapshot>(
                  stream: categoriasSnap,
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError) {
                      return const Text('Algo deu errado');
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Text('Loading');
                    }
                    return ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: snapshot.data!.docs
                                .map((DocumentSnapshot document) {
                              // print(docu)
                              Color? buttonColor = AppColors.verde;
                              Map<String, dynamic> data =
                                  document.data()! as Map<String, dynamic>;
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ElevatedButton(
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              filtroSelecionado
                                                      .contains(data['nome'])
                                                  ? AppColors.amarelo
                                                  : AppColors.verde),
                                    ),
                                    onLongPress: () {
                                      removerCategoria(document, data);
                                    },
                                    onPressed: () {
                                      filter(data, buttonColor);
                                      setState(() {});
                                    },
                                    child: Text(data['nome'])),
                              );
                            }).toList(),
                          ),
                        ]);
                  },
                ),
              ),
              StreamBuilder<QuerySnapshot>(
                  stream: produtos,
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError) {
                      return const Text('Algo deu errado');
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Text('Loading');
                    }
                    if (snapshot.connectionState == ConnectionState.active &&
                        filtroSelecionado.isEmpty) {
                      for (var document in snapshot.data!.docs) {
                        Map<String, dynamic> data =
                            document.data()! as Map<String, dynamic>;
                        data['uid'] = document.id;
                        Produto item = Produto.fromMap(data);
                        categList.add(item.categoria);
                      }
                      return const Text('Selecione um Filtro');
                    }

                    return Expanded(
                      child: ListView(
                        padding: const EdgeInsets.only(bottom: 100),
                        children: snapshot.data!.docs
                            .map((DocumentSnapshot document) {
                          Map<String, dynamic> data =
                              document.data()! as Map<String, dynamic>;
                          data['uid'] = document.id;
                          Produto item = Produto.fromMap(data);
                          categList.add(item.categoria);
                          if (filtroSelecionado.contains(item.categoria)) {
                            return GestureDetector(
                              onLongPress: () {
                                removerProduto(item);
                              },
                              onTap: () {
                                addOrEditProdutoDialog(
                                    edit: true, produto: item);
                              },
                              child: ItemCard(
                                produto: item,
                                carrinhoDeCompras: carrinhoDeCompras,
                                adminPage: true,
                              ),
                            );
                          } else if (filtroSelecionado.isEmpty) {
                            return const Text('Selecione um Filtro');
                          } else {
                            return Container();
                          }
                        }).toList(),
                      ),
                    );
                  }),
            ],
          ),
          StreamBuilder<QuerySnapshot>(
              stream: pedidos,
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return const Text('Algo deu errado');
                } else if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Text('Loading');
                } else {
                  return ListView(
                    padding: const EdgeInsets.only(bottom: 100),
                    children:
                        snapshot.data!.docs.map((DocumentSnapshot document) {
                      Map<String, dynamic> data =
                          document.data()! as Map<String, dynamic>;

                      List produtoList = data['produtos'];
                      return SizedBox(
                        height: size.height,
                        child: ListView.builder(
                          padding: const EdgeInsets.only(bottom: 150),
                          itemCount: produtoList.length,
                          itemBuilder: (context, index) {
                            Produto item = Produto.fromMap(produtoList[index]);
                            return ItemCard(
                              pedidoPage: true,
                              pedidoDetails: data,
                              adminPage: true,
                              produto: item,
                              carrinhoDeCompras: carrinhoDeCompras,
                            );
                          },
                        ),
                      );
                    }).toList(),
                  );
                }
              })
        ]),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            addOrEditProdutoDialog();
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  detalhesDoPedido(data) {
    showDialog(
      context: context,
      builder: (context) {
        return AboutDialog(
          children: [],
        );
      },
    );
  }
}
