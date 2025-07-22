import 'package:flutter/material.dart';
import 'package:cashcare/features/recommendation/recommendation_service.dart';

class AISuggestionScreen extends StatefulWidget {
  @override
  State<AISuggestionScreen> createState() => _AISuggestionScreenState();
}

class _AISuggestionScreenState extends State<AISuggestionScreen> {
  final AISuggestionService aiService = AISuggestionService();
  String? suggestionText;
  bool loading = false;
  String? error;

  @override
  void initState() {
    super.initState();
    _fetchSuggestion();
  }

  Future<void> _fetchSuggestion() async {
    setState(() {
      loading = true;
      error = null;
      suggestionText = null;
    });
    try {
      final data = await aiService.generateSuggestion();
      setState(() => suggestionText = data['suggestion'] as String?);
    } catch (e) {
      setState(() => error = e.toString());
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lines = suggestionText
        ?.trim()
        .split('\n')
        .where((line) => line.isNotEmpty)
        .toList() ??
        [];

    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text('AI Financial Advisor',
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black87)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.black54),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(children: [
            Expanded(
              child: loading
                  ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Color(0xFFE3F2FD),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: SizedBox(
                          width: 40,
                          height: 40,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation(Color(0xFF1976D2)),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 24),
                    Text(
                      'Analyzing your financial patterns...',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Our AI is generating personalized recommendations',
                      style: TextStyle(fontSize: 14, color: Colors.black38),
                    ),
                  ],
                ),
              )
                  : error != null
                  ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Color(0xFFFFEBEE),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.error_outline,
                          size: 40, color: Color(0xFFD32F2F)),
                    ),
                    SizedBox(height: 24),
                    Text(
                      'Unable to generate advice',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87),
                    ),
                    SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(error!,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, color: Colors.black54)),
                    ),
                    SizedBox(height: 24),
                    Material(
                      elevation: 0,
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: _fetchSuggestion,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          child: Text(
                            'TRY AGAIN',
                            style: TextStyle(
                              color: Color(0xFF1976D2),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
                  : suggestionText == null
                  ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Color(0xFFE8F5E9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.auto_awesome,
                          size: 40, color: Color(0xFF388E3C)),
                    ),
                    SizedBox(height: 24),
                    Text(
                      'No suggestions yet',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Tap below to get personalized financial advice',
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                  ],
                ),
              )
                  : SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 16,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Color(0xFFE3F2FD),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.psychology,
                              color: Color(0xFF1976D2), size: 20),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'AI Financial Advisor',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87),
                        ),
                      ]),
                      SizedBox(height: 16),
                      ...lines.map((line) {
                        final isHeader = line.length > 2 &&
                            '0123456789'.contains(line[0]) &&
                            line[1] == '.';
                        final isSubHeader = line.contains(':');
                        final isBullet = line.startsWith('-');
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (isHeader || isSubHeader)
                                Text(
                                  isHeader
                                      ? line.substring(line.indexOf('.') + 1).trim()
                                      : line.split(':')[0],
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                    height: 1.5,
                                  ),
                                ),
                              if (isSubHeader) SizedBox(height: 4),
                              Text(
                                isSubHeader
                                    ? line.split(':')[1].trim()
                                    : isHeader
                                    ? ''
                                    : isBullet
                                    ? '• ${line.substring(1).trim()}'
                                    : line,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black54,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      SizedBox(height: 16),
                      Divider(height: 1, color: Colors.grey[200]),
                      SizedBox(height: 16),
                      Text(
                        'Remember: These are AI-generated recommendations. Consider consulting a financial advisor for personalized advice.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black38,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            Material(
              elevation: 2,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: loading ? null : _fetchSuggestion,
                child: Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: loading ? Colors.grey[300] : Color(0xFF1976D2),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (loading)
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      else
                        Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                      SizedBox(width: 12),
                      Text(
                        loading ? 'Generating...' : 'Generate New Advice',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ]),
        ),
      ),
    );
  }
}
