<?php

namespace App\Filament\Resources\LessonResource\RelationManagers;

use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\RelationManagers\RelationManager;
use Filament\Tables;
use Filament\Tables\Table;

class VocabularyItemsRelationManager extends RelationManager
{
    protected static string $relationship = 'vocabularyItems';

    protected static ?string $title = '關鍵字詞';

    protected static ?string $modelLabel = '字詞';

    public function form(Form $form): Form
    {
        return $form->schema([
            Forms\Components\TextInput::make('term')->label('字詞')->required(),
            Forms\Components\TextInput::make('meaning')->label('意思')->required(),
            Forms\Components\TextInput::make('example')->label('例句'),
            Forms\Components\TextInput::make('sort')->label('排序')->numeric()->default(0),
        ]);
    }

    public function table(Table $table): Table
    {
        return $table
            ->recordTitleAttribute('term')
            ->columns([
                Tables\Columns\TextColumn::make('sort')->label('#'),
                Tables\Columns\TextColumn::make('term')->label('字詞')->weight('bold'),
                Tables\Columns\TextColumn::make('meaning')->label('意思'),
                Tables\Columns\TextColumn::make('example')->label('例句')->limit(40),
            ])
            ->defaultSort('sort')
            ->headerActions([
                Tables\Actions\CreateAction::make(),
            ])
            ->actions([
                Tables\Actions\EditAction::make(),
                Tables\Actions\DeleteAction::make(),
            ])
            ->bulkActions([
                Tables\Actions\DeleteBulkAction::make(),
            ]);
    }
}
