library universal_ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:universal_html/html.dart' as html;
import 'package:visual_editor/documents/models/nodes/embed.model.dart';
import 'package:visual_editor/visual-editor.dart';

import '../widgets/responsive-widget.dart';
import 'fake-ui.dart' if (dart.library.html) 'real-ui.dart' as ui_instance;

class PlatformViewRegistryFix {
  void registerViewFactory(dynamic x, dynamic y) {
    if (kIsWeb) {
      ui_instance.PlatformViewRegistry.registerViewFactory(
        x,
        y,
      );
    }
  }
}

class UniversalUI {
  PlatformViewRegistryFix platformViewRegistry = PlatformViewRegistryFix();
}

var ui = UniversalUI();

Widget defaultEmbedBuilderWeb(
  BuildContext context,
  EditorController controller,
  EmbedM node,
  bool readOnly,
) {
  switch (node.value.type) {
    case 'image':
      final imageUrl = node.value.data;
      final size = MediaQuery.of(context).size;
      UniversalUI().platformViewRegistry.registerViewFactory(
            imageUrl,
            (viewId) => html.ImageElement()..src = imageUrl,
          );

      return Padding(
        padding: EdgeInsets.only(
          right: ResponsiveWidget.isMediumScreen(context)
              ? size.width * 0.5
              : (ResponsiveWidget.isLargeScreen(context))
                  ? size.width * 0.75
                  : size.width * 0.2,
        ),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.45,
          child: HtmlElementView(
            viewType: imageUrl,
          ),
        ),
      );

    default:
      // Throwing an error here does not help at all.
      // Even when there's only one Operation with a video attribute in the whole doc
      // it will be flushed away from the console by a large callstack.
      // The error that gets printed on repeat will flood the terminal filling up the entire buffer
      // with a message that is completely misleading.
      // By rendering this text we can save countless hours of searching for the origin of the bug.
      // ignore: avoid_print
      print(
        'Embeddable type "${node.value.type}" is not supported by default '
        'embed builder of VisualEditor. You must pass your own builder function '
        'to embedBuilder property of VisualEditor or EditorField widgets.',
      );
      return const SizedBox.shrink();
  }
}