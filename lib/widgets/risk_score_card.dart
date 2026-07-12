import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/language_provider.dart';
import '../services/ai_scoring_service.dart';
import '../models/risk_score_model.dart';
import '../utils/languages.dart';

class RiskScoreCard extends StatefulWidget {
  const RiskScoreCard({super.key});

  @override
  State<RiskScoreCard> createState() => _RiskScoreCardState();
}

class _RiskScoreCardState extends State<RiskScoreCard> {
  RiskScoreModel? _riskScore;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _calculateRiskScore();
  }

  void _calculateRiskScore() {
    final auth = context.read<AuthProvider>();

    final age = int.tryParse(auth.usia) ?? 3;
    final weight = double.tryParse(auth.bb) ?? 14.0;
    final height = double.tryParse(auth.tb) ?? 95.0;

    // Data vital dummy (nanti dari smartwatch)
    final spo2 = 97.0;
    final hr = 110.0;

    final languageProvider = context.read<LanguageProvider>();
    final isEnglish = languageProvider.currentLanguage == 'en';

    final result = AIScoringService.predict(
      age: age,
      weight: weight,
      height: height,
      spo2: spo2,
      hr: hr,
      isEnglish: isEnglish,
    );

    setState(() {
      _riskScore = RiskScoreModel.fromMap(result);
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final lang = AppLocalizations.of(context)!;
    final auth = context.watch<AuthProvider>();
    final languageProvider = context.watch<LanguageProvider>();
    final isEnglish = languageProvider.currentLanguage == 'en';
    final isProfileEmpty = auth.nama.isEmpty && auth.usia.isEmpty;

    if (isProfileEmpty) {
      return _buildEmptyCard(lang);
    }

    if (_isLoading) {
      return _buildLoadingCard();
    }

    final score = _riskScore!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Score circle
              SizedBox(
                width: 70,
                height: 70,
                child: Stack(
                  children: [
                    Center(
                      child: SizedBox(
                        width: 70,
                        height: 70,
                        child: CircularProgressIndicator(
                          value: score.score / 100,
                          backgroundColor: Colors.grey.shade200,
                          strokeWidth: 8,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            score.levelColor,
                          ),
                        ),
                      ),
                    ),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${score.score}',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: score.levelColor,
                            ),
                          ),
                          Text(
                            '/ 100',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lang.riskScore,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1B3A5C),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: score.levelColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        score.getLevelText(!isEnglish),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: score.levelColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      score.explanation,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Status detail - SpO2 & HR
          const SizedBox(height: 8),
          Row(
            children: [
              _buildStatusChip(
                label: 'SpO₂',
                status: score.spo2Status,
                isId: !isEnglish,
              ),
              const SizedBox(width: 8),
              _buildStatusChip(
                label: 'HR',
                status: score.hrStatus,
                isId: !isEnglish,
              ),
            ],
          ),
          if (score.level != 'NORMAL') ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: score.levelColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: score.levelColor.withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: score.levelColor,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      score.recommendation,
                      style: TextStyle(
                        fontSize: 11,
                        color: score.levelColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          // Tips
          if (score.tips.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.grey.shade200,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isEnglish ? '💡 Tips:' : '💡 Tips:',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  ...score.tips.map((tip) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 1),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '• ',
                          style: TextStyle(
                            fontSize: 10,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            tip,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusChip({
    required String label,
    required String status,
    required bool isId,
  }) {
    final color = _getStatusColor(status);
    final text = _getStatusText(status, isId);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '$label: $text',
            style: TextStyle(
              fontSize: 9,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'bahaya':
        return Colors.red;
      case 'waspada':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  String _getStatusText(String status, bool isId) {
    switch (status) {
      case 'bahaya':
        return isId ? 'Kritis' : 'Critical';
      case 'waspada':
        return isId ? 'Perlu Perhatian' : 'Needs Attention';
      default:
        return isId ? 'Normal' : 'Normal';
    }
  }

  Widget _buildLoadingCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 70,
            height: 70,
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFF4FC3F7),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 80,
                  height: 16,
                  color: Colors.grey.shade200,
                ),
                const SizedBox(height: 8),
                Container(
                  width: 120,
                  height: 12,
                  color: Colors.grey.shade200,
                ),
                const SizedBox(height: 4),
                Container(
                  width: double.infinity,
                  height: 12,
                  color: Colors.grey.shade200,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCard(AppLocalizations lang) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          lang.belumAdaRiskScore,
          style: TextStyle(
            color: Colors.grey.shade400,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}