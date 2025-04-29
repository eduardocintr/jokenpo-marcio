import 'package:flutter/material.dart';
import 'dart:math';

class Jogo extends StatefulWidget {
  const Jogo({super.key});

  @override
  State<Jogo> createState() => _JogoState();
}

class _JogoState extends State<Jogo> {
  int pontosUsuario = 0;
  int pontosApp = 0;
  String resultado = '';
  String escolhaApp = 'padrao';
  String escolhaUsuario = 'padrao';
  bool jogadaBloqueada = false;
  List<String> historico = [];

  void jogar(String escolha) async {
    if (jogadaBloqueada) return;

    setState(() {
      jogadaBloqueada = true;
      escolhaUsuario = escolha;
      escolhaApp = 'padrao';
      resultado = '';
    });

    // Efeito piscando antes de revelar a escolha do app
    await Future.delayed(const Duration(milliseconds: 400));
    setState(() {
      escolhaApp = 'loading';
    });
    await Future.delayed(const Duration(milliseconds: 400));

    List<String> opcoes = ['pedra', 'papel', 'tesoura'];
    String novaEscolhaApp = opcoes[Random().nextInt(opcoes.length)];

    setState(() {
      escolhaApp = novaEscolhaApp;
    });

    await Future.delayed(const Duration(milliseconds: 400));

    // Lógica do jogo
    if (escolha == escolhaApp) {
      resultado = 'Empate!';
    } else if ((escolha == 'pedra' && escolhaApp == 'tesoura') ||
        (escolha == 'papel' && escolhaApp == 'pedra') ||
        (escolha == 'tesoura' && escolhaApp == 'papel')) {
      resultado = 'Você ganhou!';
      pontosUsuario++;
    } else {
      resultado = 'Você perdeu!';
      pontosApp++;
    }

    // Adicionar ao histórico (máximo 5 partidas)
    historico.insert(0, resultado);
    if (historico.length > 5) {
      historico.removeLast();
    }

    setState(() {});

    await Future.delayed(const Duration(milliseconds: 800));
    setState(() {
      jogadaBloqueada = false;
    });
  }

  void reiniciarJogo() {
    setState(() {
      pontosUsuario = 0;
      pontosApp = 0;
      resultado = '';
      escolhaApp = 'padrao';
      escolhaUsuario = 'padrao';
      historico.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: resultado == 'Você ganhou!'
          ? Colors.green[100]
          : resultado == 'Você perdeu!'
              ? Colors.red[100]
              : resultado == 'Empate!'
                  ? Colors.blue[100]
                  : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        title: const Text('JokenPO'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: reiniciarJogo,
          ),
        ],
      ),
      body: SingleChildScrollView(
        // ⬅ Aqui está a correção do erro de overflow
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            // Exibição da pontuação
            Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 10),
              child: Text(
                "Pontuação\nVocê: $pontosUsuario - App: $pontosApp",
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            // Escolha do usuário e do app
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                escolhaVisivel("Sua Escolha", escolhaUsuario),
                escolhaVisivel("Escolha do App", escolhaApp),
              ],
            ),

            // Exibição do resultado
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                resultado,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: resultado == 'Você ganhou!'
                      ? Colors.green
                      : resultado == 'Você perdeu!'
                          ? Colors.red
                          : Colors.blue,
                ),
              ),
            ),

            // Histórico das últimas partidas
            const Text(
              "Últimas Partidas:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: historico.map((res) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Icon(
                      res == 'Você ganhou!'
                          ? Icons.check_circle
                          : res == 'Você perdeu!'
                              ? Icons.cancel
                              : Icons.remove_circle,
                      color: res == 'Você ganhou!'
                          ? Colors.green
                          : res == 'Você perdeu!'
                              ? Colors.red
                              : Colors.blue,
                      size: 30,
                    ),
                  );
                }).toList(),
              ),
            ),

            // Escolha de jogada
            const Padding(
              padding: EdgeInsets.only(top: 16, bottom: 16),
              child: Text(
                "Escolha uma opção abaixo:",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),

            // Botões de jogada com nomes e destaque na escolha
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                escolhaBotao('pedra'),
                escolhaBotao('papel'),
                escolhaBotao('tesoura'),
              ],
            ),

            const SizedBox(height: 20),

            // Botão para reiniciar a pontuação
            ElevatedButton(
              onPressed: reiniciarJogo,
              child: const Text("Reiniciar Jogo"),
            ),
          ],
        ),
      ),
    );
  }

  Widget escolhaVisivel(String titulo, String escolha) {
    return Column(
      children: [
        Text(
          titulo,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Image.asset(
          'images/${escolha == 'loading' ? 'padrao' : escolha}.png',
          height: 100,
        ),
      ],
    );
  }

  Widget escolhaBotao(String escolha) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => jogar(escolha),
          child: Image.asset('images/$escolha.png', height: 100),
        ),
        Text(
          escolha[0].toUpperCase() + escolha.substring(1),
          style: const TextStyle(fontSize: 18),
        ),
      ],
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: Jogo(),
  ));
}
