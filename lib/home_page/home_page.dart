import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sergipe_shop/administrar_produto_page/admin_page.dart';
import 'package:sergipe_shop/finalizar_pedido/finalizar_page.dart';
import 'package:sergipe_shop/home_page/widgets/item_card.dart';
import 'package:sergipe_shop/login_page/login_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sergipe_shop/models/produto_model.dart';
import 'package:sergipe_shop/utils/app_colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  FirebaseAuth auth = FirebaseAuth.instance;

  sair() async {
    // await auth.cle
    await auth.signOut();
    await GoogleSignIn().signOut();
    auth.currentUser == null;
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginPage(
            homePage: true,
          ),
        ));
  }

  var produtos = FirebaseFirestore.instance.collection('produtos').snapshots();
  var categorias =
      FirebaseFirestore.instance.collection('categorias').snapshots();

  ValueNotifier<List<Produto>> carrinhoDeCompras = ValueNotifier([]);

  Future<void> comprar(Produto produto) async {
    carrinhoDeCompras.value.add(produto);

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    carrinhoDeCompras.dispose();
  }

  List<String> filtroSelecionado = [];
  // var buttonFilterColor = Colors.green;
  filter(Map<String, dynamic> data, Color? color) {
    // filtroSelecionado.add(data['nome']);
    String filter = data['nome'];

    if (filtroSelecionado.contains(filter)) {
      filtroSelecionado.remove(filter);
    } else {
      filtroSelecionado.add(filter);
    }
  }

  List<String> categList = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Sergipe Shopping'),
        leading: Padding(
          padding: const EdgeInsets.all(3.0),
          child: CircleAvatar(
            backgroundImage: NetworkImage(currentUser.photoURL ??
                'https://avatar-management--avatars.us-west-2.prod.public.atl-paas.net/default-avatar.png'),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              sair();
            },
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 70,
            child: StreamBuilder<QuerySnapshot>(
              stream: categorias,
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return const Text('Algo deu errado');
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Text('Loading');
                }
                return ListView(scrollDirection: Axis.horizontal, children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    // mainAxisSize: MainAxisSize.max,
                    // scrollDirection: Axis.horizontal,
                    children:
                        snapshot.data!.docs.map((DocumentSnapshot document) {
                      Color? buttonColor = AppColors.verde;
                      Map<String, dynamic> data =
                          document.data()! as Map<String, dynamic>;
                      categList.add(data['nome']);
                      categList.toSet().toList();
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(
                                  filtroSelecionado.contains(data['nome'])
                                      ? AppColors.amarelo
                                      : AppColors.verde),
                            ),
                            onPressed: () {
                              filter(data, buttonColor);
                              categList.toSet().toList();

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
              } else if (snapshot.connectionState == ConnectionState.waiting) {
                return const Text('Carregando');
              } else if (snapshot.connectionState == ConnectionState.active &&
                  filtroSelecionado.isEmpty) {
                return const Text('Selecione um Filtro');
              } else {
                return Expanded(
                  child: ListView(
                    padding: const EdgeInsets.only(bottom: 100),
                    children:
                        snapshot.data!.docs.map((DocumentSnapshot document) {
                      Map<String, dynamic> data =
                          document.data()! as Map<String, dynamic>;
                      data['uid'] = document.id;
                      Produto item = Produto.fromMap(data);
                      if (filtroSelecionado.contains(item.categoria)) {
                        return ItemCard(
                          produto: item,
                          carrinhoDeCompras: carrinhoDeCompras,
                        );
                      } else if (filtroSelecionado.isEmpty) {
                        return const Text('Selecione um Filtro');
                      } else {
                        return Container();
                      }
                    }).toList(),
                  ),
                );
              }
            },
          ),
        ],
      ),
      bottomSheet: ValueListenableBuilder(
        valueListenable: carrinhoDeCompras,
        builder: (context, List<Produto> value, child) {
          return carrinhoDeCompras.value.isEmpty
              ? const SizedBox(
                  height: 0,
                  width: 0,
                )
              : Container(
                  padding: const EdgeInsets.only(left: 10),
                  color: Colors.yellow,
                  width: double.infinity,
                  height: 90,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: Row(
                        children: [
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            'Itens no Carrinho ${carrinhoDeCompras.value.length}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                          ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => FinalizarPage(
                                          produtos: carrinhoDeCompras),
                                    ));
                              },
                              child: const Text('Finalizar')),
                        ],
                      ),
                    ),
                  ),
                );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: currentUser.email! == 'admin@sergipe.com'
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdminPage(),
                    ));
              },
              child: const Icon(
                Icons.add,
              ))
          : Container(),
    );
  }
}
