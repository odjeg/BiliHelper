import 'package:bilihelper/models/crawler/crawler_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ClawlerPage extends ConsumerStatefulWidget {
  const ClawlerPage({super.key});

  @override
  ConsumerState<ClawlerPage> createState() => _ClawlerPageState();
}

class _ClawlerPageState extends ConsumerState<ClawlerPage> {
  final TextEditingController _controller = TextEditingController();
  @override
  initState() {
    super.initState();
    _controller.text = ref.read(crawlerProvider.select((value) => value.url));
  }

  @override
  Widget build(BuildContext context) {
    final errorText = ref.watch(crawlerProvider.select((s) => s.errorText));
    ref.listen<String?>(crawlerProvider.select((value) => value.url), (
      previous,
      current,
    ) {
      _controller.text = current ?? '';
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length),
      );
    });
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Scaffold(
        body: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextSelectionTheme(
                    data: TextSelectionThemeData(
                      cursorColor: Colors.pink[200],
                      selectionColor: Color.fromARGB(50, 244, 143, 177),
                      selectionHandleColor: Colors.pink[200],
                    ),
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        labelText: '输入链接',
                        border: OutlineInputBorder(),
                        floatingLabelStyle: TextStyle(color: Colors.pink[200]),
                        hoverColor: Colors.pink[200],
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.pink.shade200),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.clear),
                          onPressed: () {
                            ref.read(crawlerProvider.notifier).updateUrl('');
                          },
                        ),
                        errorText: errorText == '' ? null : errorText,
                        errorStyle: TextStyle(height: 0, fontSize: 0),
                      ),
                      onChanged: (value) {
                        ref.read(crawlerProvider.notifier).updateUrl(value);
                      },
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Clipboard.getData(Clipboard.kTextPlain).then((value) {
                      if (value != null) {
                        ref
                            .read(crawlerProvider.notifier)
                            .updateUrl(value.text!);
                      }
                    });
                  },
                  icon: Icon(Icons.paste),
                ),
              ],
            ),
            Expanded(child: Container()),
          ],
        ),
      ),
    );
  }
}
