import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../business/providers/brick_type_provider.dart';
import '../../data/models/brick_type.dart';
import '../../core/utils/formatters.dart';
import 'brick_type_form_screen.dart';

/// Brick type list screen with status filtering
/// 
/// Displays list of brick types with search, status filter,
/// and category filter capabilities. Allows navigation to brick type form
/// for creating and editing brick types.
class BrickTypeListScreen extends StatefulWidget {
  const BrickTypeListScreen({super.key});

  @override
  State<BrickTypeListScreen> createState() => _BrickTypeListScreenState();
}

class _BrickTypeListScreenState extends State<BrickTypeListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BrickTypeProvider>().fetchBrickTypes();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Brick Type Management'),
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildSearchAndFilters(),
          Expanded(child: _buildBrickTypeList()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToBrickTypeForm(null),
        icon: const Icon(Icons.add),
        label: const Text('Add Brick Type'),
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
      child: Column(
        children: [
          // Search field
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search brick types...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        context.read<BrickTypeProvider>().setSearchQuery(null);
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            onChanged: (value) {
              if (value.isEmpty) {
                context.read<BrickTypeProvider>().setSearchQuery(null);
              }
            },
            onSubmitted: (value) {
              context.read<BrickTypeProvider>().setSearchQuery(
                    value.isEmpty ? null : value,
                  );
            },
          ),
          const SizedBox(height: 12),
          // Filter chips
          _buildFilterChips(),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Consumer<BrickTypeProvider>(
      builder: (context, provider, child) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              // Status filter
              _buildStatusFilterChip(provider),
              const SizedBox(width: 8),
              // Clear filters
              if (provider.filterStatus != null)
                ActionChip(
                  label: const Text('Clear Filters'),
                  onPressed: () => provider.clearFilters(),
                  avatar: const Icon(Icons.clear, size: 18),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusFilterChip(BrickTypeProvider provider) {
    return FilterChip(
      label: Text(
        provider.filterStatus != null
            ? provider.filterStatus!.toUpperCase()
            : 'All Status',
      ),
      selected: provider.filterStatus != null,
      onSelected: (_) => _showStatusFilterDialog(provider),
    );
  }

  Widget _buildBrickTypeList() {
    return Consumer<BrickTypeProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.brickTypes.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                const SizedBox(height: 16),
                Text(
                  provider.error!,
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => provider.fetchBrickTypes(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (provider.brickTypes.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.category_outlined, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No brick types found',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => provider.fetchBrickTypes(),
          child: ListView.builder(
            itemCount: provider.brickTypes.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final brickType = provider.brickTypes[index];
              return _buildBrickTypeCard(brickType);
            },
          ),
        );
      },
    );
  }

  Widget _buildBrickTypeCard(BrickType brickType) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: brickType.isActive ? Colors.orange : Colors.grey,
          child: const Icon(Icons.category, color: Colors.white),
        ),
        title: Text(
          brickType.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            if (brickType.description != null && brickType.description!.isNotEmpty)
              Text(
                brickType.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildInfoChip(
                  brickType.currentPrice != null && brickType.unit != null
                      ? '${Formatters.currency(brickType.priceAsDouble)}/${brickType.unit}'
                      : brickType.currentPrice != null
                          ? Formatters.currency(brickType.priceAsDouble)
                          : brickType.unit != null
                              ? 'Unit: ${brickType.unit}'
                              : 'Price not set',
                  Colors.green,
                  Icons.attach_money,
                ),
                const SizedBox(width: 8),
                if (brickType.category != null && brickType.category!.isNotEmpty)
                  _buildInfoChip(
                    brickType.category!,
                    Colors.blue,
                    Icons.label,
                  ),
                const SizedBox(width: 8),
                _buildInfoChip(
                  brickType.status.toUpperCase(),
                  brickType.isActive ? Colors.green : Colors.grey,
                  Icons.circle,
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleBrickTypeAction(value, brickType),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 20),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'update_price',
              child: Row(
                children: [
                  Icon(Icons.price_change, size: 20),
                  SizedBox(width: 8),
                  Text('Update Price'),
                ],
              ),
            ),
            PopupMenuItem(
              value: brickType.isActive ? 'deactivate' : 'activate',
              child: Row(
                children: [
                  Icon(
                    brickType.isActive ? Icons.block : Icons.check_circle,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(brickType.isActive ? 'Deactivate' : 'Activate'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 20, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
        onTap: () => _navigateToBrickTypeForm(brickType),
      ),
    );
  }

  Widget _buildInfoChip(String label, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _handleBrickTypeAction(String action, BrickType brickType) {
    switch (action) {
      case 'edit':
        _navigateToBrickTypeForm(brickType);
        break;
      case 'update_price':
        _showUpdatePriceDialog(brickType);
        break;
      case 'activate':
      case 'deactivate':
        _confirmStatusChange(brickType);
        break;
      case 'delete':
        _confirmDelete(brickType);
        break;
    }
  }

  Future<void> _navigateToBrickTypeForm(BrickType? brickType) async {
    final provider = context.read<BrickTypeProvider>();
    
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider.value(
          value: provider,
          child: BrickTypeFormScreen(brickType: brickType),
        ),
      ),
    );

    if (result == true && mounted) {
      provider.fetchBrickTypes();
    }
  }

  void _showUpdatePriceDialog(BrickType brickType) {
    final priceController = TextEditingController(text: brickType.currentPrice ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Price'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Current Price: ${brickType.displayPrice}'),
            const SizedBox(height: 16),
            TextField(
              controller: priceController,
              decoration: const InputDecoration(
                labelText: 'New Price',
                prefixText: '₹ ',
                border: OutlineInputBorder(),
                hintText: 'Enter new price (optional)',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 8),
            Text(
              'Note: This will affect all future orders',
              style: TextStyle(
                fontSize: 12,
                color: Colors.orange[700],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _updatePrice(brickType.id, priceController.text.trim());
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _confirmStatusChange(BrickType brickType) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${brickType.isActive ? 'Deactivate' : 'Activate'} Brick Type'),
        content: Text(
          'Are you sure you want to ${brickType.isActive ? 'deactivate' : 'activate'} ${brickType.name}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _updateStatus(brickType);
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BrickType brickType) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Brick Type'),
        content: Text('Are you sure you want to delete ${brickType.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteBrickType(brickType);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _updatePrice(int id, String newPrice) async {
    final provider = context.read<BrickTypeProvider>();
    final success = await provider.updateBrickTypePrice(id, newPrice);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(provider.successMessage ?? 'Price updated')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error ?? 'Failed to update price'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _updateStatus(BrickType brickType) async {
    final provider = context.read<BrickTypeProvider>();
    final newStatus = brickType.isActive ? 'inactive' : 'active';
    final success = await provider.updateBrickTypeStatus(brickType.id, newStatus);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(provider.successMessage ?? 'Status updated')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error ?? 'Failed to update status'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteBrickType(BrickType brickType) async {
    final provider = context.read<BrickTypeProvider>();
    final success = await provider.deleteBrickType(brickType.id);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(provider.successMessage ?? 'Brick type deleted')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error ?? 'Failed to delete brick type'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showStatusFilterDialog(BrickTypeProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter by Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('All Status'),
              onTap: () {
                provider.setStatusFilter(null);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Active'),
              onTap: () {
                provider.setStatusFilter('active');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Inactive'),
              onTap: () {
                provider.setStatusFilter('inactive');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
