import React from 'react';
import {
  View, Text, FlatList, Image,
  TouchableHighlight, Alert,
} from 'react-native';

import { cleanImage } from '../api/shopApi';
import { CartItem } from '../utils/types';
import { CartProps } from '../navigation/MyStacks';
import { cartStyle } from '../utils/styles';

type Props = { cart: CartProps };

export default function CartScreen({ cart }: Props) {
  const { items, removeFromCart, updateQuantity, clearCart, totalItems, totalPrice } = cart;

  const handleConfirmOrder = () => {
    Alert.alert(
      'Conferma ordine',
      `Confermi l'ordine di ${totalItems} prodotti per € ${totalPrice.toFixed(2)}?`,
      [
        { text: 'Annulla', style: 'cancel' },
        {
          text: 'Conferma',
          onPress: () => {
            clearCart();
            Alert.alert('Ordine confermato! ✅', 'Grazie per il tuo acquisto.');
          },
        },
      ]
    );
  };

  const handleClearCart = () => {
    Alert.alert('Svuota carrello', 'Vuoi rimuovere tutti i prodotti?', [
      { text: 'Annulla', style: 'cancel' },
      { text: 'Svuota', style: 'destructive', onPress: clearCart },
    ]);
  };

  if (items.length === 0) {
    return (
      <View style={cartStyle.emptyContainer}>
        <Text style={cartStyle.emptyIcon}>🛒</Text>
        <Text style={cartStyle.emptyTitle}>Il carrello è vuoto</Text>
        <Text style={cartStyle.emptySubtitle}>Aggiungi prodotti dal catalogo</Text>
      </View>
    );
  }

  return (
    <View style={cartStyle.container}>
      <FlatList
        data={items}
        keyExtractor={item => String(item.product.id)}
        contentContainerStyle={cartStyle.listContent}
        renderItem={({ item }) => <CartItemCard item={item} onRemove={removeFromCart} onUpdateQuantity={updateQuantity} />}
        ListFooterComponent={<SummaryCard totalItems={totalItems} totalPrice={totalPrice} />}
      />

      {/* Footer pulsanti */}
      <View style={cartStyle.footer}>
        <TouchableHighlight
          style={cartStyle.confirmBtn}
          onPress={handleConfirmOrder}
          underlayColor="#2a3eb1"
        >
          <Text style={cartStyle.confirmText}>🛒  Conferma ordine</Text>
        </TouchableHighlight>

        <TouchableHighlight
          style={cartStyle.clearBtn}
          onPress={handleClearCart}
          underlayColor="#E8EAFD"
        >
          <Text style={cartStyle.clearText}>🗑  Svuota carrello</Text>
        </TouchableHighlight>
      </View>
    </View>
  );
}

// ── Card prodotto nel carrello ────────────────────────────
function CartItemCard({ item, onRemove, onUpdateQuantity }: {
  item: CartItem;
  onRemove: (id: number) => void;
  onUpdateQuantity: (id: number, qty: number) => void;
}) {
  return (
    <View style={cartStyle.card}>
      <Image
        source={{ uri: cleanImage(item.product.images[0]) }}
        style={cartStyle.image}
        resizeMode="cover"
      />
      <View style={{ flex: 1 }}>
        <View style={{ flexDirection: 'row', alignItems: 'flex-start' }}>
          <Text style={cartStyle.name} numberOfLines={2}>{item.product.title}</Text>
          <TouchableHighlight
            onPress={() => onRemove(item.product.id)}
            underlayColor="transparent"
            style={cartStyle.deleteBtn}
          >
            <Text style={{ fontSize: 18, color: '#9CA3AF' }}>🗑</Text>
          </TouchableHighlight>
        </View>

        <Text style={cartStyle.price}>€ {item.product.price.toFixed(2)}</Text>

        {/* Stepper quantità */}
        <View style={{ flexDirection: 'row', justifyContent: 'space-between', alignItems: 'flex-end', marginTop: 6 }}>
          <View>
            <Text style={{ fontSize: 11, color: '#6B7280', marginBottom: 4 }}>Quantità</Text>
            <View style={cartStyle.stepper}>
              <TouchableHighlight
                style={cartStyle.stepBtn}
                onPress={() => onUpdateQuantity(item.product.id, item.quantity - 1)}
                underlayColor="transparent"
              >
                <Text style={cartStyle.stepText}>−</Text>
              </TouchableHighlight>
              <Text style={cartStyle.qty}>{item.quantity}</Text>
              <TouchableHighlight
                style={cartStyle.stepBtn}
                onPress={() => onUpdateQuantity(item.product.id, item.quantity + 1)}
                underlayColor="transparent"
              >
                <Text style={cartStyle.stepText}>+</Text>
              </TouchableHighlight>
            </View>
          </View>
          <View style={{ alignItems: 'flex-end' }}>
            <Text style={cartStyle.subtotalLabel}>Subtotale</Text>
            <Text style={cartStyle.subtotal}>€ {(item.product.price * item.quantity).toFixed(2)}</Text>
          </View>
        </View>
      </View>
    </View>
  );
}

// ── Riepilogo totale ──────────────────────────────────────
function SummaryCard({ totalItems, totalPrice }: { totalItems: number; totalPrice: number }) {
  return (
    <View style={cartStyle.summaryCard}>
      <View style={cartStyle.summaryRow}>
        <Text style={cartStyle.summaryIcon}>🛍️</Text>
        <Text style={cartStyle.summaryLabel}>Numero totale prodotti</Text>
        <Text style={cartStyle.summaryValue}>{totalItems}</Text>
      </View>
      <View style={cartStyle.divider} />
      <View style={cartStyle.summaryRow}>
        <Text style={cartStyle.summaryIcon}>💳</Text>
        <Text style={cartStyle.totalLabel}>Totale complessivo</Text>
        <Text style={cartStyle.totalValue}>€ {totalPrice.toFixed(2)}</Text>
      </View>
    </View>
  );
}
