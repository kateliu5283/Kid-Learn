<x-filament-widgets::widget>
    <div
        class="fi-section rounded-xl bg-white p-6 shadow-sm ring-1 ring-gray-950/5 dark:bg-gray-900 dark:ring-white/10"
    >
        <h3 class="text-base font-semibold text-gray-950 dark:text-white">孩子的學習狀態</h3>

        @if ($students->isEmpty())
            <p class="mt-2 text-sm text-gray-600 dark:text-gray-400">
                目前<strong>雲端尚無孩子資料</strong>。請在手機 App 以同一家長帳號<strong>註冊或登入</strong>，並開啟「上傳／同步本機孩子」；完成後重新整理此頁，或從左側選單進入「我的孩子」查看。
            </p>
        @else
            <p class="mt-2 text-sm text-gray-600 dark:text-gray-400">
                以下為已同步至雲端的孩子（與 App 本機檔對應）。<strong>各課程完成度、練習紀錄</strong>目前仍儲存在 App 本機，尚未上傳至伺服器，故網頁無法顯示細項；請在手機上查看學習進度。日後若開放學習紀錄 API，會再顯示於此。
            </p>
            <div class="mt-4 overflow-x-auto rounded-lg ring-1 ring-gray-950/5 dark:ring-white/10">
                <table class="min-w-full divide-y divide-gray-200 text-sm dark:divide-white/10">
                    <thead class="bg-gray-50 dark:bg-white/5">
                        <tr>
                            <th class="px-4 py-2 text-left font-medium text-gray-900 dark:text-white">姓名</th>
                            <th class="px-4 py-2 text-left font-medium text-gray-900 dark:text-white">年級</th>
                            <th class="px-4 py-2 text-left font-medium text-gray-900 dark:text-white">學習進度（雲端）</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-gray-100 dark:divide-white/10">
                        @foreach ($students as $student)
                            <tr>
                                <td class="px-4 py-2 text-gray-900 dark:text-white">
                                    <span class="mr-1">{{ $student->avatar ?? '' }}</span>{{ $student->name }}
                                </td>
                                <td class="px-4 py-2 text-gray-700 dark:text-gray-300">{{ $student->grade }} 年級</td>
                                <td class="px-4 py-2 text-gray-500 dark:text-gray-400">尚未同步（請於 App 查看）</td>
                            </tr>
                        @endforeach
                    </tbody>
                </table>
            </div>
            <p class="mt-3 text-xs text-gray-500 dark:text-gray-500">
                若要編輯姓名或年級，請使用左側「我的孩子」。
            </p>
        @endif
    </div>
</x-filament-widgets::widget>
