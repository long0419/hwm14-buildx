program hwm14_cli
    use hwm_interface, only : hwm_14
    implicit none

    real(8) :: glat, glon, alt_km
    integer :: doy
    real(8) :: utsec, ap
    real(8) :: w_merid, w_zonal
    integer :: narg
    character(len=64) :: arg

    narg = command_argument_count()
    if (narg < 5 .or. narg > 6) then
        print *, "Usage: hwm14_cli <lat> <lon> <alt_km> <doy> <ut_seconds> [ap]"
        stop 1
    end if

    call get_command_argument(1, arg); read(arg, *) glat
    call get_command_argument(2, arg); read(arg, *) glon
    call get_command_argument(3, arg); read(arg, *) alt_km
    call get_command_argument(4, arg); read(arg, *) doy
    call get_command_argument(5, arg); read(arg, *) utsec

    if (narg >= 6) then
        call get_command_argument(6, arg); read(arg, *) ap
    else
        ap = 4.0d0
    end if

    call hwm_14(doy, utsec, alt_km, glat, glon, ap, w_merid, w_zonal)

    ! 两行输出，兼容 Python 解析：DW(1)/DW(2) 先写成 0.0 占位
    write(*,'(A)') "Wmeridional   Wzonal   DW(1)   DW(2)"
    write(*,'(4F14.6)') w_merid, w_zonal, 0.0d0, 0.0d0

end program hwm14_cli
