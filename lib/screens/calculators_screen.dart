import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../services/ad_service.dart';

class CalculatorsScreen extends StatefulWidget {
  const CalculatorsScreen({super.key});

  @override
  State<CalculatorsScreen> createState() => _CalculatorsScreenState();
}

class _CalculatorsScreenState extends State<CalculatorsScreen> {
  String _calcType = 'concrete';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Construction Calculators', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildTypeSelector(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _buildCalculatorForm(),
            ),
          ),
          const CustomBannerAd(),
        ],
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      color: Colors.blue[50],
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _typeButton('concrete', LucideIcons.box, 'Concrete'),
            _typeButton('bricks', LucideIcons.layout, 'Bricks'),
            _typeButton('steel', LucideIcons.activity, 'Steel'),
            _typeButton('tiles', LucideIcons.grid, 'Tiles'),
          ],
        ),
      ),
    );
  }

  Widget _typeButton(String type, IconData icon, String label) {
    bool isSelected = _calcType == type;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ChoiceChip(
        label: Text(label),
        avatar: Icon(icon, size: 16, color: isSelected ? Colors.white : Colors.blue),
        selected: isSelected,
        onSelected: (val) => setState(() => _calcType = type),
        selectedColor: Colors.blue[600],
        labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.blue[800]),
      ),
    );
  }

  Widget _buildCalculatorForm() {
    switch (_calcType) {
      case 'concrete': return const ConcreteCalculator();
      case 'bricks': return const BrickCalculator();
      case 'steel': return const SteelCalculator();
      case 'tiles': return const TileCalculator();
      default: return const SizedBox();
    }
  }
}

class ConcreteCalculator extends StatefulWidget {
  const ConcreteCalculator({super.key});

  @override
  State<ConcreteCalculator> createState() => _ConcreteCalculatorState();
}

class _ConcreteCalculatorState extends State<ConcreteCalculator> {
  final _lController = TextEditingController();
  final _wController = TextEditingController();
  final _dController = TextEditingController();
  String _ratio = '1:2:4';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Concrete Volume Calculator', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildInput('Length (ft)', _lController),
        _buildInput('Width (ft)', _wController),
        _buildInput('Depth/Thickness (ft)', _dController),
        const SizedBox(height: 16),
        const Text('Mix Ratio (Cement:Sand:Aggregate)'),
        DropdownButton<String>(
          value: _ratio,
          isExpanded: true,
          items: ['1:1.5:3', '1:2:4', '1:3:6', '1:4:8'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (val) => setState(() => _ratio = val!),
        ),
        const SizedBox(height: 24),
        _buildResults(),
      ],
    );
  }

  Widget _buildInput(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
        onChanged: (_) => setState(() {}),
      ),
    );
  }

  Widget _buildResults() {
    double l = double.tryParse(_lController.text) ?? 0;
    double w = double.tryParse(_wController.text) ?? 0;
    double d = double.tryParse(_dController.text) ?? 0;
    double volume = l * w * d;
    double dryVolume = volume * 1.54;

    List<double> parts = _ratio.split(':').map((e) => double.parse(e)).toList();
    double totalParts = parts.reduce((a, b) => a + b);

    double cementBags = (dryVolume / totalParts) * parts[0] / 1.226;
    double sand = (dryVolume / totalParts) * parts[1];
    double aggregate = (dryVolume / totalParts) * parts[2];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(8)),
      child: Column(
        children: [
          _resultRow('Total Volume', '${volume.toStringAsFixed(2)} Cu.Ft'),
          _resultRow('Cement Required', '${cementBags.toStringAsFixed(1)} Bags'),
          _resultRow('Sand Required', '${sand.toStringAsFixed(1)} Cu.Ft'),
          _resultRow('Aggregate Required', '${aggregate.toStringAsFixed(1)} Cu.Ft'),
        ],
      ),
    );
  }

  Widget _resultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(label), Text(value, style: const TextStyle(fontWeight: FontWeight.bold))],
      ),
    );
  }
}

// Placeholder for other calculators to keep it concise
class BrickCalculator extends StatefulWidget {
  const BrickCalculator({super.key});

  @override
  State<BrickCalculator> createState() => _BrickCalculatorState();
}

class _BrickCalculatorState extends State<BrickCalculator> {
  final _lController = TextEditingController();
  final _hController = TextEditingController();
  final _tController = TextEditingController(text: '9'); // 9 inch or 4.5 inch wall
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Brick Work Calculator', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildInput('Wall Length (ft)', _lController),
        _buildInput('Wall Height (ft)', _hController),
        _buildInput('Wall Thickness (inches)', _tController),
        const SizedBox(height: 24),
        _buildResults(),
      ],
    );
  }

  Widget _buildInput(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
        onChanged: (_) => setState(() {}),
      ),
    );
  }

  Widget _buildResults() {
    double l = double.tryParse(_lController.text) ?? 0;
    double h = double.tryParse(_hController.text) ?? 0;
    double t = (double.tryParse(_tController.text) ?? 0) / 12.0;
    
    double volume = l * h * t;
    // Standard brick size 190x90x90mm -> with mortar 200x100x100mm
    // In Cu.Ft, roughly 13.5 bricks per Cu.Ft
    double totalBricks = volume * 13.5;
    double cementBags = volume * 0.06; // Rough estimate
    double sand = volume * 0.25; // Rough estimate

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(8)),
      child: Column(
        children: [
          _resultRow('Total Volume', '${volume.toStringAsFixed(2)} Cu.Ft'),
          _resultRow('Bricks Required', '${totalBricks.toStringAsFixed(0)} Nos'),
          _resultRow('Cement Required', '${cementBags.toStringAsFixed(1)} Bags'),
          _resultRow('Sand Required', '${sand.toStringAsFixed(1)} Cu.Ft'),
        ],
      ),
    );
  }

  Widget _resultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(label), Text(value, style: const TextStyle(fontWeight: FontWeight.bold))],
      ),
    );
  }
}

class SteelCalculator extends StatefulWidget {
  const SteelCalculator({super.key});

  @override
  State<SteelCalculator> createState() => _SteelCalculatorState();
}

class _SteelCalculatorState extends State<SteelCalculator> {
  final _lengthController = TextEditingController();
  final _diaController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Steel Weight Calculator', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildInput('Total Length (meters)', _lengthController),
        _buildInput('Diameter (mm)', _diaController),
        const SizedBox(height: 24),
        _buildResults(),
      ],
    );
  }

  Widget _buildInput(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
        onChanged: (_) => setState(() {}),
      ),
    );
  }

  Widget _buildResults() {
    double l = double.tryParse(_lengthController.text) ?? 0;
    double d = double.tryParse(_diaController.text) ?? 0;
    
    // Weight (kg) = (D^2 / 162) * L
    double weight = (d * d / 162.2) * l;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(8)),
      child: Column(
        children: [
          _resultRow('Total Weight', '${weight.toStringAsFixed(2)} Kg'),
          _resultRow('Weight in Quintal', '${(weight / 100).toStringAsFixed(2)} Q'),
        ],
      ),
    );
  }

  Widget _resultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(label), Text(value, style: const TextStyle(fontWeight: FontWeight.bold))],
      ),
    );
  }
}

class TileCalculator extends StatefulWidget {
  const TileCalculator({super.key});

  @override
  State<TileCalculator> createState() => _TileCalculatorState();
}

class _TileCalculatorState extends State<TileCalculator> {
  final _lController = TextEditingController();
  final _wController = TextEditingController();
  final _tileLController = TextEditingController(text: '2');
  final _tileWController = TextEditingController(text: '2');

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Tiles Calculator', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        const Text('Floor/Wall Area:', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _buildInput('Length (ft)', _lController)),
            const SizedBox(width: 12),
            Expanded(child: _buildInput('Width (ft)', _wController)),
          ],
        ),
        const SizedBox(height: 16),
        const Text('Single Tile Size:', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _buildInput('Length (ft)', _tileLController)),
            const SizedBox(width: 12),
            Expanded(child: _buildInput('Width (ft)', _tileWController)),
          ],
        ),
        const SizedBox(height: 24),
        _buildResults(),
      ],
    );
  }

  Widget _buildInput(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
        onChanged: (_) => setState(() {}),
      ),
    );
  }

  Widget _buildResults() {
    double l = double.tryParse(_lController.text) ?? 0;
    double w = double.tryParse(_wController.text) ?? 0;
    double tl = double.tryParse(_tileLController.text) ?? 1;
    double tw = double.tryParse(_tileWController.text) ?? 1;
    
    double area = l * w;
    double tileArea = tl * tw;
    double totalTiles = area / tileArea;
    // Add 10% wastage
    double tilesWithWastage = totalTiles * 1.1;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(8)),
      child: Column(
        children: [
          _resultRow('Total Area', '${area.toStringAsFixed(2)} Sq.Ft'),
          _resultRow('Tiles Needed', '${totalTiles.toStringAsFixed(0)} Nos'),
          _resultRow('With 10% Wastage', '${tilesWithWastage.toStringAsFixed(0)} Nos'),
        ],
      ),
    );
  }

  Widget _resultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(label), Text(value, style: const TextStyle(fontWeight: FontWeight.bold))],
      ),
    );
  }
}
