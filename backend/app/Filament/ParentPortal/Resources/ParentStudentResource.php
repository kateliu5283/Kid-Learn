<?php

namespace App\Filament\ParentPortal\Resources;

use App\Filament\ParentPortal\Resources\ParentStudentResource\Pages;
use App\Models\Student;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;

/**
 * 家長後台專用：僅能管理本人名下雲端學生（與 /admin 的 StudentResource 分離）。
 */
class ParentStudentResource extends Resource
{
    protected static ?string $model = Student::class;

    protected static ?string $slug = 'my-children';

    protected static ?string $navigationIcon = 'heroicon-o-user-group';

    protected static ?string $navigationLabel = '我的孩子';

    protected static ?string $modelLabel = '孩子';

    protected static ?string $pluralModelLabel = '我的孩子';

    protected static ?int $navigationSort = 1;

    public static function getEloquentQuery(): Builder
    {
        return parent::getEloquentQuery()
            ->where('parent_user_id', auth()->id());
    }

    public static function form(Form $form): Form
    {
        return $form->schema([
            Forms\Components\Section::make()->schema([
                Forms\Components\TextInput::make('name')
                    ->label('顯示名稱')
                    ->required()
                    ->maxLength(120),
                Forms\Components\Select::make('grade')
                    ->label('年級')
                    ->options([
                        1 => '1 年級', 2 => '2 年級', 3 => '3 年級', 4 => '4 年級', 5 => '5 年級', 6 => '6 年級',
                    ])
                    ->required()
                    ->native(false),
                Forms\Components\TextInput::make('avatar')
                    ->label('頭像（emoji）')
                    ->maxLength(32),
                Forms\Components\TextInput::make('device_local_id')
                    ->label('App 本機對應 id')
                    ->maxLength(64)
                    ->disabled()
                    ->dehydrated()
                    ->visibleOn('edit')
                    ->helperText('由 App 註冊／登入同步時寫入，網頁僅供查看。'),
                Forms\Components\TextInput::make('sort')
                    ->label('排序')
                    ->numeric()
                    ->default(0)
                    ->required(),
            ]),
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('name')
                    ->label('姓名')
                    ->searchable()
                    ->sortable(),
                Tables\Columns\TextColumn::make('grade')
                    ->label('年級')
                    ->formatStateUsing(fn ($state): string => "{$state} 年級")
                    ->sortable(),
                Tables\Columns\TextColumn::make('avatar')->label('頭像')->placeholder('—'),
                Tables\Columns\TextColumn::make('device_local_id')
                    ->label('本機 id')
                    ->placeholder('—')
                    ->toggleable(),
                Tables\Columns\TextColumn::make('updated_at')
                    ->label('最後更新')
                    ->dateTime('Y-m-d H:i')
                    ->sortable(),
            ])
            ->defaultSort('sort')
            ->actions([
                Tables\Actions\EditAction::make(),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make(),
                ]),
            ]);
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListParentStudents::route('/'),
            'create' => Pages\CreateParentStudent::route('/create'),
            'edit' => Pages\EditParentStudent::route('/{record}/edit'),
        ];
    }
}
