package com.example.ripasso_compose.di

import com.example.ripasso_compose.data.models.Cart
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent
import javax.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
object CartModule {

    @Provides
    @Singleton
    fun provideCart(): Cart {
        return Cart()
    }
}