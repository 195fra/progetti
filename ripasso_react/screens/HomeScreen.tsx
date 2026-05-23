import React, { useEffect, useState } from 'react';
import {
  View, Text, FlatList, ActivityIndicator,
  TouchableHighlight, Alert,
} from 'react-native';
import { useNavigation } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';

import { getProductList } from '../api/shopApi';
import { Product } from '../utils/types';
import { MyStackParamList, CartProps } from '../navigation/MyStacks';
import ProductCard from '../components/ProductCard';
import { homeStyle } from '../utils/styles';

type Nav = NativeStackNavigationProp<MyStackParamList, 'Home'>;

type Props = { cart: CartProps };

export default function HomeScreen({ cart }: Props) {
  const navigation = useNavigation<Nav>();

  const [products, setProducts] = useState<Product[]>([]);
  const [loading, setLoading]   = useState(true);
  const [error, setError]       = useState<string | null>(null);

  useEffect(() => { loadProducts(); }, []);

  const loadProducts = async () => {
    try {
      setLoading(true);
      setError(null);
      const data = await getProductList();
      setProducts(data);
    } catch (e) {
      setError('Errore durante il caricamento. Riprova.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <View style={{ flex: 1, backgroundColor: '#F5F5F5' }}>

      <View style={{ flex: 1 }}>
        <Text style={[homeStyle.title, { padding: 10 }]}>Prodotti</Text>

        {loading && (
          <ActivityIndicator size="large" color="#3D5AFE" style={homeStyle.loader} />
        )}

        {error && !loading && (
          <Text style={homeStyle.errorText}>{error}</Text>
        )}

        {!loading && !error && (
          <FlatList
            data={products}
            keyExtractor={item => String(item.id)}
            contentContainerStyle={{ padding: 10 }}
            renderItem={({ item }) => (
              <ProductCard
                product={item}
                onPress={() => navigation.navigate('ProductDetail', { productId: item.id })}
              />
            )}
          />
        )}
      </View>

      {/* Barra carrello in fondo — come la bottom bar del progetto originale */}
      {cart.totalItems > 0 && (
        <View style={homeStyle.cartBar}>
          <View>
            <Text style={homeStyle.cartBarText}>
              🛍️ {cart.totalItems} {cart.totalItems === 1 ? 'prodotto' : 'prodotti'} nel carrello
            </Text>
            <Text style={homeStyle.cartBarTotal}>
              Totale: € {cart.totalPrice.toFixed(2)}
            </Text>
          </View>
          <TouchableHighlight
            style={homeStyle.cartBarButton}
            onPress={() => navigation.navigate('Cart')}
            underlayColor="#2a3eb1"
          >
            <Text style={homeStyle.cartBarButtonText}>🛒 Vai al carrello</Text>
          </TouchableHighlight>
        </View>
      )}

    </View>
  );
}
