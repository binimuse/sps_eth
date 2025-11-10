import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sps_eth_app/app/modules/form_class/views/widget/scanning_document_view.dart';

class ChatMessage {
  final String text;
  final bool isFromOP; // true if from OP (Officer/Operator), false if from other party
  final String time;

  ChatMessage({
    required this.text,
    required this.isFromOP,
    required this.time,
  });
}

typedef ActionCallback = void Function(BuildContext context);

class ActionTileConfig {
  const ActionTileConfig({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final ActionCallback onPressed;
}

class InfoRow {
  const InfoRow(this.label, this.value);

  final String label;
  final String value;
}

class DocumentItem {
  const DocumentItem({
    required this.label,
    required this.fileName,
  });

  final String label;
  final String fileName;
}

class CallClassController extends GetxController {
  final messages = <ChatMessage>[].obs;

  final messageController = TextEditingController();

  final selectedLanguage = 'English'.obs;
  final TextEditingController keyboardController = TextEditingController();
  TextEditingController? focusedController;
  FocusNode? focusedField = FocusNode();

  final RxList<ActionTileConfig> actionTiles = <ActionTileConfig>[].obs;
  final RxList<InfoRow> idInformation = <InfoRow>[].obs;
  final RxList<DocumentItem> supportingDocuments = <DocumentItem>[].obs;
  final RxString termsAndConditions =
      'These are the terms and conditions for Loreim re in charge of planning and managing marketing campaigns that promote a company\'s brand.'
          .obs;
  final RxString discussionDate = 'June 12, 2024'.obs;

  @override
  void onInit() {
    super.onInit();
    _loadInitialData();
  }

  void _loadInitialData() {
    messages.assignAll([
      ChatMessage(
        text:
            "Lorem Ipsum has been the industry's standard dummy text ever since the 1500s",
        isFromOP: true,
        time: '8:00 PM',
      ),
      ChatMessage(
        text:
            "Lorem Ipsum has been the industry's standard dummy text ever since the 1500s",
        isFromOP: false,
        time: '8:00 PM',
      ),
      ChatMessage(
        text:
            "Lorem Ipsum has been the industry's standard dummy text ever since the 1500s",
        isFromOP: true,
        time: '8:00 PM',
      ),
      ChatMessage(
        text:
            "Lorem Ipsum has been the industry's standard dummy text ever since the 1500s",
        isFromOP: false,
        time: '8:00 PM',
      ),
    ]);

    actionTiles.assignAll([
      ActionTileConfig(
        icon: Icons.document_scanner,
        label: 'Scan Document',
        onPressed: (context) => ScanningDocumentView.show(context),
      ),
      ActionTileConfig(
        icon: Icons.person,
        label: 'Take Photo',
        onPressed: (_) => onTakePhoto(),
      ),
      ActionTileConfig(
        icon: Icons.usb,
        label: 'Flash  Documents',
        onPressed: (_) => onFlashDocuments(),
      ),
      ActionTileConfig(
        icon: Icons.receipt_long,
        label: 'Payment Receipt',
        onPressed: (_) => onPaymentReceipt(),
      ),
    ]);

    idInformation.assignAll(const [
      InfoRow('ID Information', '1231235163'),
      InfoRow('Name  Information', 'Abeba Shimeles Adera'),
      InfoRow('Birth Date', 'Aug 12 , 2024'),
      InfoRow('Email', 'abeba@gmail.com'),
      InfoRow('Phone Number', '0913427553'),
      InfoRow('Residence Address', '–'),
    ]);

    supportingDocuments.assignAll(const [
      DocumentItem(label: 'Incident Document', fileName: 'Doc name.pdf'),
      DocumentItem(label: 'Application', fileName: 'Doc name.pdf'),
      DocumentItem(label: 'Others', fileName: 'Doc name.pdf'),
    ]);
  }

  @override
  void onClose() {
    messageController.dispose();
    keyboardController.dispose();
    focusedField?.dispose();
    super.onClose();
  }

  void sendMessage() {
    final text = messageController.text.trim();
    if (text.isEmpty) return;

    final now = DateTime.now();
    final hour = now.hour == 0 ? 12 : now.hour > 12 ? now.hour - 12 : now.hour;
    final timeString =
        '$hour:${now.minute.toString().padLeft(2, '0')} ${now.hour >= 12 ? 'PM' : 'AM'}';

    messages.add(
      ChatMessage(
        text: text,
        isFromOP: true,
        time: timeString,
      ),
    );

    messageController.clear();
  }

  void cancelCall() {
    Get.back();
  }

  void confirmTerms() {
    // Placeholder for confirm action (e.g., API call)
  }

  void onTakePhoto() {
    // Placeholder for future photo capture integration
  }

  void onFlashDocuments() {
    // Placeholder for future flash document handling
  }

  void onPaymentReceipt() {
    // Placeholder for future payment receipt handling
  }

  void setFocusedField(
    FocusNode? focusNode,
    TextEditingController textController,
  ) {
    focusedField = focusNode;
    focusedController = textController;
    keyboardController
      ..text = textController.text
      ..selection = textController.selection;
  }

  void onKeyboardKeyPressed(String key) {
    final controller = focusedController;
    if (controller == null) return;

    final text = controller.text;
    final selection = controller.selection;

    if (key == 'backspace') {
      if (selection.start > 0) {
        final newText =
            text.substring(0, selection.start - 1) + text.substring(selection.end);
        controller
          ..text = newText
          ..selection = TextSelection.collapsed(offset: selection.start - 1);
      }
    } else if (key == 'space') {
      final newText =
          text.substring(0, selection.start) + ' ' + text.substring(selection.end);
      controller
        ..text = newText
        ..selection = TextSelection.collapsed(offset: selection.start + 1);
    } else if (key == 'left') {
      if (selection.start > 0) {
        controller.selection =
            TextSelection.collapsed(offset: selection.start - 1);
      }
    } else if (key == 'right') {
      if (selection.end < text.length) {
        controller.selection =
            TextSelection.collapsed(offset: selection.end + 1);
      }
    } else if (key == 'enter') {
      final newText =
          text.substring(0, selection.start) + '\n' + text.substring(selection.end);
      controller
        ..text = newText
        ..selection = TextSelection.collapsed(offset: selection.start + 1);
    } else if (key == '123') {
      // Future enhancement: switch keyboard layout
    } else {
      final newText =
          text.substring(0, selection.start) + key + text.substring(selection.end);
      controller
        ..text = newText
        ..selection = TextSelection.collapsed(offset: selection.start + key.length);
    }

    keyboardController
      ..text = controller.text
      ..selection = controller.selection;
  }

  void clearMessage() {
    messageController.clear();
  }
}
