import cv2
import numpy as np

def compare_images(image1_path, image2_path):
    """
    2つの画像を比較し、差分を表示する関数
    
    Args:
        image1_path (str) : 1つ目の画像のパス
        image2_path (str) : 2つ目の画像のパス
    """
    
    # 画像の読み込み
    image1 = cv2.imread(image1_path)
    image2 = cv2.imread(image2_path)
    
    # 画像をリサイズするためにサイズ調整
    height = image2.shape[0]
    width = image2.shape[1]
    
    image1 = cv2.resize(image1 , (int(width), int(height)))
    
    # Grayスケールに変更
    # image1_gray = cv2.cvtColor(image1, cv2.COLOR_BGR2GRAY)
    # image2_gray = cv2.cvtColor(image2, cv2.COLOR_BGR2GRAY)
    
    # 差分画像を計算
    # gray_diff = cv2.absdiff(image1_gray, image2_gray)
    diff = cv2.absdiff(image1, image2)
    
    # グレースケールに変換
    gray2 = cv2.cvtColor(image2, cv2.COLOR_BGR2GRAY)
    gray_diff = cv2.cvtColor(diff, cv2.COLOR_BGR2GRAY)
    
    # BGRからRGBに変換
    image1_rgb = cv2.cvtColor(image1, cv2.COLOR_BGR2RGB)
    image2_rgb = cv2.cvtColor(image2, cv2.COLOR_BGR2RGB)
    
    # カラーマップを適用するために差分画像を正規化
    norm_diff = gray_diff / np.max(gray_diff)
    
    # 差分画像に重みをかけて2枚目の画像の色に反映
    diff_img = cv2.addWeighted(gray2, 0.1, gray_diff, 2, 100)
    
    diff_colored = np.zeros_like(image2_rgb)
    diff_colored[..., 0] = image2_rgb[..., 0] * norm_diff
    diff_colored[..., 1] = image2_rgb[..., 1] * norm_diff
    diff_colored[..., 2] = image2_rgb[..., 2] * norm_diff
    
    # 結果をファイルに出力
    prefix_diff_img = "GrayScaled_"
    prefix_diff_colored = "ColoredScaled_"
    cv2.imwrite(prefix_diff_img + "diff.png", diff_img)
    cv2.imwrite(prefix_diff_colored + "diff.png",diff_colored)
    
if __name__ == "__main__":
    # 2つの画像を比較して違いを検出
    image1_path = "./a/c.png"
    image2_path = "./b/d.png"
    compare_images(image1_path, image2_path)