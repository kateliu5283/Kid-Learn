<?php

namespace App\Filament\Resources;

use App\Filament\Resources\SubjectResource\Pages;
use App\Models\Subject;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;

class SubjectResource extends Resource
{
    protected static ?string $model = Subject::class;

    protected static ?string $navigationIcon = 'heroicon-o-book-open';

    protected static ?string $navigationGroup = '課程內容';

    protected static ?string $modelLabel = '學科';

    protected static ?string $pluralModelLabel = '學科';

    protected static ?int $navigationSort = 1;

    public static function form(Form $form): Form
    {
        return $form->schema([
            Forms\Components\TextInput::make('code')
                ->label('學科代碼')
                ->helperText('英文代碼，例如：chinese / math / english')
                ->required()
                ->unique(ignoreRecord: true)
                ->maxLength(32),
            Forms\Components\TextInput::make('name')
                ->label('名稱')
                ->required()
                ->maxLength(32),
            Forms\Components\TextInput::make('english_name')
                ->label('英文名稱')
                ->maxLength(32),
            Forms\Components\TextInput::make('icon')
                ->label('Material Icon 名稱')
                ->helperText('對應 Flutter 端 Icons.xxx')
                ->maxLength(64),
            Forms\Components\ColorPicker::make('color')
                ->label('主色'),
            Forms\Components\Textarea::make('description')
                ->label('描述')
                ->rows(2)
                ->maxLength(500),
            Forms\Components\TextInput::make('sort')
                ->label('排序')
                ->numeric()
                ->default(0),
            Forms\Components\Toggle::make('is_active')
                ->label('啟用')
                ->default(true),
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('sort')->label('#')->sortable(),
                Tables\Columns\ColorColumn::make('color')->label('顏色'),
                Tables\Columns\TextColumn::make('code')->label('代碼')->badge(),
                Tables\Columns\TextColumn::make('name')->label('名稱')->searchable(),
                Tables\Columns\TextColumn::make('lessons_count')
                    ->label('課程數')
                    ->counts('lessons')
                    ->badge(),
                Tables\Columns\TextColumn::make('questions_count')
                    ->label('題目數')
                    ->counts('questions')
                    ->badge()
                    ->color('success'),
                Tables\Columns\IconColumn::make('is_active')
                    ->label('啟用')
                    ->boolean(),
            ])
            ->defaultSort('sort')
            ->actions([
                Tables\Actions\EditAction::make(),
                Tables\Actions\DeleteAction::make(),
            ])
            ->bulkActions([
                Tables\Actions\DeleteBulkAction::make(),
            ]);
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListSubjects::route('/'),
            'create' => Pages\CreateSubject::route('/create'),
            'edit' => Pages\EditSubject::route('/{record}/edit'),
        ];
    }
}
