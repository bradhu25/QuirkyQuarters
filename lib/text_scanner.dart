import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:quirky_quarters/utils.dart';

RegExp basicAmountPattern = RegExp(r'^.*?(\d+\.\d{2}).*$');

Future<Receipt?> processImageToParseReceipt(String imagePath) async {
  Set<List<String>> parsedTextWIP = {};
  final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final recognizedText = await textRecognizer.processImage(inputImage);
      parsedTextWIP = parseTextIntoLines(recognizedText);
      parsedTextWIP = filterLinesWithAmounts(parsedTextWIP);
      parsedTextWIP = filterOutTotals(parsedTextWIP);
      return parseIntoReceipt(parsedTextWIP);

  } catch (e) {
      print(e);
      return null;
  }
}

Set<List<String>> parseTextIntoLines(RecognizedText text) {
  int tolerance = 50;
  Map<double, List<String>> rows = {};

  for (TextBlock block in text.blocks) {
    for (TextLine line in block.lines) {
      
      final double rightValue = line.boundingBox.right;

      List<String>? foundRow;

      for (double rowRight in rows.keys){         
          if((rowRight - rightValue).abs() <= tolerance){
              foundRow = rows[rowRight];
              break;
          }
      }

      foundRow ??= [];
      rows[rightValue] = foundRow;
      foundRow.add(line.text);
    }
  }

  Set<List<String>> combinedLines = {};
  for (List<String> lines in rows.values) {
    combinedLines.add(lines);
  }

  return combinedLines;
}

Set<List<String>> filterLinesWithAmounts(Set<List<String>> text) {
  Set<List<String>> filtered = {};

  for (List<String> list in text) {
    for (int i = 0; i < list.length; i++) {
      Match? match = basicAmountPattern.firstMatch(list[i]);
      if (match != null) {
        // Clean up list before adding it.
        list[i] = match.group(1)!;
        
        if (!list[0].contains("%")) {
          filtered.add(list);
        }

        break;
      }
    }
  }

  return filtered;
}

Set<List<String>> filterOutTotals(Set<List<String>> text) {
  // Track total, substotal, balance due, etc.
  double maxAmount = -1;
  Set<List<String>> maxAmountLists = {};
  double secondMaxAmount = -1;
  Set<List<String>> secondMaxAmountLists = {};

  for (List<String> list in text) {
    for (String elem in list) {
        Match? match = basicAmountPattern.firstMatch(elem);
        if (match != null) {
          double amount = double.parse(match.group(1)!);
          if (amount > maxAmount) {
            secondMaxAmount = maxAmount;
            secondMaxAmountLists = maxAmountLists;
            maxAmount = amount;
            maxAmountLists = {list};
          } else if (amount == maxAmount) {
            maxAmountLists.add(list);
          } else if (amount > secondMaxAmount && amount < maxAmount) {
            secondMaxAmount = amount;
            secondMaxAmountLists = {list};
          } else if (amount == secondMaxAmount) {
            secondMaxAmountLists.add(list);
          }
          break;
        }
    }
  }

  // Remove max amount found since it is likely to be the total.
  for (List<String> list in maxAmountLists) {
    text.remove(list);
  }

  // Remove second max amount found since it is likely to be the subtotal.
  for (List<String> list in secondMaxAmountLists) {
    text.remove(list);
  }

  return text;
}

Receipt parseIntoReceipt(Set<List<String>> text) {
  Receipt receipt = Receipt.emptyReceipt();
  double total = 0.0;
  for (List<String> list in text) {
    if (list.length < 2) {
      continue;
    }
    
    String item = list[0];
    double cost = double.parse(list[1]);

    if (item.toLowerCase().contains("tax")) {
      receipt.tax = cost;
    } else {
      total += cost;
      receipt.entries.add(ItemCostPayer(item: item, cost: cost, payer: null));
    }
  }

  receipt.title = "";
  receipt.total = total;
  return receipt;
}