import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:poor_rich/data/income_preset_data.dart';
import '../../utils/number_formatter.dart';

class MyIncomePage extends StatelessWidget {
  const MyIncomePage({
    super.key,
    required this.myIncome,
    required this.myIncomeController,
    required this.onIncomeChanged,
  });
  final double myIncome;
  final TextEditingController myIncomeController;
  final Function(double) onIncomeChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            'あなたの年収を設定',
            style: GoogleFonts.notoSansJp(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '現在の年収を入力してください',
            style: GoogleFonts.notoSansJp(
              fontSize: 16,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 24),

          // 年収入力フィールド
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: myIncomeController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: GoogleFonts.notoSansJp(fontSize: 18),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: (value) {
                      onIncomeChanged(double.tryParse(value) ?? 0);
                    },
                  ),
                ),
                Text(
                  '万円',
                  style: GoogleFonts.notoSansJp(
                    fontSize: 18,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // プリセット選択
          Text(
            'または、プリセットから選択',
            style: GoogleFonts.notoSansJp(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),

          // プリセットグリッドビューを固定の高さに設定
          SizedBox(
            height: 300, // 固定の高さを設定
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 2.5,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: IncomePresetData.presets.length,
              itemBuilder: (context, index) {
                final preset = IncomePresetData.presets[index];
                final presetInManYen = preset.amount / 10000;
                final isSelected = myIncome == presetInManYen;

                return GestureDetector(
                  onTap: () {
                    onIncomeChanged(presetInManYen);
                    myIncomeController.text = presetInManYen.round().toString();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? Theme.of(context).primaryColor.withOpacity(0.1)
                              : Colors.grey.shade50,
                      border: Border.all(
                        color:
                            isSelected
                                ? Theme.of(context).primaryColor
                                : Colors.grey.shade300,
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          preset.name,
                          style: GoogleFonts.notoSansJp(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${NumberFormatter.formatNumberWithCommas(presetInManYen)} 万円',
                          style: GoogleFonts.notoSansJp(
                            fontSize: 11,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
