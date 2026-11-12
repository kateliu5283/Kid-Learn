<?php

namespace App\Notifications;

use Illuminate\Auth\Notifications\ResetPassword;
use Illuminate\Notifications\Messages\MailMessage;

class ResetParentPassword extends ResetPassword
{
    protected function buildMailMessage($url): MailMessage
    {
        $minutes = (int) config('auth.passwords.'.config('auth.defaults.passwords').'.expire');

        return (new MailMessage)
            ->subject('重設小學堂家長帳號密碼')
            ->line('我們收到重設家長帳號密碼的要求。請點擊下方按鈕設定新密碼。')
            ->action('設定新密碼', $url)
            ->line("此連結將於 {$minutes} 分鐘後失效。")
            ->line('若您並未提出這個要求，請忽略此信件，密碼不會改變。');
    }
}
