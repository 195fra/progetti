import React, { useEffect, useState } from 'react';
import {
  View, Text, Image, ScrollView,
  ActivityIndicator, TouchableHighlight, Alert,
} from 'react-native';
import { RouteProp, useRoute } from '@react-navigation/native';

import { getProductDetail, cleanImage } from '../api/shopApi';
import { Product } from '../utils/types';
import { MyStackParamList } from '../navigation/MyStacks';
import { detailStyle } from '../utils/styles';

type Route = RouteProp<MyStackParamList, 'ProductDetail'>;

type Props = {
  addToCart: (product: Product) => void;
};

export default function ProductDetailScreen({ addToCart }: Props) {
  const { productId } = useRoute<Route>().params;

  const [product, setProduct] = useState<Product | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError]     = useState<string | null>(null);

  useEffect(() => { load(); }, []);

  const load = async () => {
    try {
      setLoading(true);
      setError(null);
      const data = await getProductDetail(productId);
      setProduct(data);
    } catch (e) {
      setError('Impossibile caricare il prodotto.');
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return (
      <View style={detailStyle.loader}>
        <ActivityIndicator size="large" color="#3D5AFE" />
      </View>
    );
  }

  if (error || !product) {
    return (
      <View style={detailStyle.loader}>
        <Text style={{ color: 'red' }}>{error}</Text>
      </View>
    );
  }

  const handleAddToCart = () => {
    addToCart(product);
    Alert.alert(
      'Aggiunto al carrello ✅',
      `${product.title} è stato aggiunto al carrello.`
    );
  };

  return (
    <View style={{ flex: 1, backgroundColor: '#F5F5F5' }}>
      <ScrollView contentContainerStyle={detailStyle.container}>

        {/* Immagine grande */}
        <Image
          source={{ uri: cleanImage(product.images[0]) }}
          style={detailStyle.image}
          resizeMode="cover"
        />

        {/* Titolo */}
        <Text style={detailStyle.name}>{product.title}</Text>

        {/* Categoria */}
        <View style={detailStyle.categoryChip}>
          <Text style={detailStyle.categoryText}>{product.category.name}</Text>
        </View>

        {/* Prezzo */}
        <Text style={detailStyle.price}>€ {product.price.toFixed(2)}</Text>

        {/* Descrizione */}
        <Text style={detailStyle.subtitle}>Descrizione</Text>
        <Text style={detailStyle.description}>{product.description}</Text>

      </ScrollView>

      {/* Pulsante fisso in fondo */}
      <View style={detailStyle.footer}>
        <TouchableHighlight
          style={detailStyle.addButton}
          onPress={handleAddToCart}
          underlayColor="#2a3eb1"
        >
          <Text style={detailStyle.addButtonText}>🛒  Aggiungi al carrello</Text>
        </TouchableHighlight>
      </View>
    </View>
  );
}
